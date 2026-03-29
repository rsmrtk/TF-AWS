# -- Managed cache policies from AWS --

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

# Enforce browser-side security via response headers. HSTS preload list
# submission requires max-age >= 1 year (63072000 s) + includeSubDomains.
resource "aws_cloudfront_response_headers_policy" "security" {
  name = "${local.name_prefix}-security-headers"

  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
  }
}

# OAC replaces the legacy OAI approach for S3 origins (sigv4 signing).
resource "aws_cloudfront_origin_access_control" "this" {
  count = local.is_s3 ? 1 : 0

  name                              = "${local.name_prefix}-oac"
  description                       = "OAC for ${local.name_prefix} S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#
# Distribution
#
resource "aws_cloudfront_distribution" "this" {
  comment             = "${local.name_prefix}-distribution"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.aliases
  web_acl_id          = var.waf_web_acl_arn != "" ? var.waf_web_acl_arn : null

  # S3 origin with OAC
  dynamic "origin" {
    for_each = local.is_s3 ? [1] : []

    content {
      domain_name              = var.origin_domain_name
      origin_id                = "${local.name_prefix}-s3-origin"
      origin_access_control_id = aws_cloudfront_origin_access_control.this[0].id
    }
  }

  # ALB origin -- always talks HTTPS back to the load balancer
  dynamic "origin" {
    for_each = local.is_s3 ? [] : [1]

    content {
      domain_name = var.origin_domain_name
      origin_id   = "${local.name_prefix}-alb-origin"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior {
    target_origin_id           = local.is_s3 ? "${local.name_prefix}-s3-origin" : "${local.name_prefix}-alb-origin"
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    allowed_methods            = local.is_s3 ? ["GET", "HEAD"] : ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods             = ["GET", "HEAD"]
    cache_policy_id            = local.is_s3 ? data.aws_cloudfront_cache_policy.caching_optimized.id : data.aws_cloudfront_cache_policy.caching_disabled.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security.id
  }

  # TLS: use the custom cert when provided, otherwise fall back to *.cloudfront.net
  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
    acm_certificate_arn            = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    ssl_support_method             = var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version       = var.acm_certificate_arn != "" ? "TLSv1.2_2021" : null
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Access logs go to a separate S3 bucket when enabled.
  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []

    content {
      bucket          = var.logging_bucket
      include_cookies = false
      prefix          = "${local.name_prefix}/"
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses

    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  tags = merge(local.common_tags, var.tags)
}
