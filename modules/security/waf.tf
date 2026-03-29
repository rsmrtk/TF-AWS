# WAF v2 Web ACL and optional logging

resource "aws_wafv2_web_acl" "this" {
  count = local.create_waf ? 1 : 0

  name        = "${local.name_prefix}-waf-acl"
  description = "WAF web ACL for ${local.name_prefix}"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Basic rate limiting -- catches simple volumetric attacks.
  rule {
    name     = "rate-limit"
    priority = 1

    action {
      dynamic "count" {
        for_each = var.waf_mode == "count" ? [1] : []
        content {}
      }
      dynamic "block" {
        for_each = var.waf_mode == "block" ? [1] : []
        content {}
      }
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      dynamic "count" {
        for_each = var.waf_mode == "count" ? [1] : []
        content {}
      }
      dynamic "none" {
        for_each = var.waf_mode == "block" ? [1] : []
        content {}
      }
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      dynamic "count" {
        for_each = var.waf_mode == "count" ? [1] : []
        content {}
      }
      dynamic "none" {
        for_each = var.waf_mode == "block" ? [1] : []
        content {}
      }
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-known-bad-inputs-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 30

    override_action {
      dynamic "count" {
        for_each = var.waf_mode == "count" ? [1] : []
        content {}
      }
      dynamic "none" {
        for_each = var.waf_mode == "block" ? [1] : []
        content {}
      }
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-sqli-rule-set"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-waf-acl"
    sampled_requests_enabled   = true
  }

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-waf-acl"
    },
  )
}

# WAF logging -- ships to CloudWatch so you can actually see what's being matched.
# The "aws-waf-logs-" prefix is required by AWS.

resource "aws_cloudwatch_log_group" "waf" {
  count = var.enable_waf ? 1 : 0

  name              = "aws-waf-logs-${local.name_prefix}"
  retention_in_days = var.waf_log_retention_days

  tags = merge(var.tags, local.common_tags)
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.enable_waf ? 1 : 0

  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]
  resource_arn            = aws_wafv2_web_acl.this[0].arn
}
