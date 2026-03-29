# --- S3 Buckets ---

resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket        = "${local.name_prefix}-${each.key}"
  force_destroy = each.value.force_destroy

  tags = merge(var.tags, local.common_tags, {
    Name    = "${local.name_prefix}-${each.key}"
    Purpose = each.value.purpose
  })
}

# Versioning

resource "aws_s3_bucket_versioning" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Suspended"
  }
}

# SSE -- KMS with bucket keys for cost savings

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null
    }
    bucket_key_enabled = true # reduces KMS request costs
  }
}

# Lock down public access at the bucket level

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rules

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = {
    for k, v in var.buckets : k => v
    if length(v.lifecycle_rules) > 0
  }

  bucket = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = each.value.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      transition {
        days          = rule.value.transition_days
        storage_class = rule.value.transition_storage_class
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days > 0 ? [rule.value.expiration_days] : []
        content {
          days = expiration.value
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days > 0 ? [rule.value.noncurrent_version_expiration_days] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

# CORS -- only for buckets that opt in

resource "aws_s3_bucket_cors_configuration" "this" {
  for_each = {
    for k, v in var.buckets : k => v
    if v.enable_cors
  }

  bucket = aws_s3_bucket.this[each.key].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = each.value.allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}

# Deny non-TLS traffic.
# Note: Principal must be "*" (not {"AWS":"*"}) for bucket-level deny policies
# to apply to anonymous callers as well.

data "aws_iam_policy_document" "enforce_tls" {
  for_each = var.buckets

  statement {
    sid    = "EnforceTLS"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.this[each.key].arn,
      "${aws_s3_bucket.this[each.key].arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  for_each = var.buckets

  bucket = aws_s3_bucket.this[each.key].id
  policy = data.aws_iam_policy_document.enforce_tls[each.key].json

  depends_on = [aws_s3_bucket_public_access_block.this]
}
