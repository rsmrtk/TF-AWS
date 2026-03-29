# --- Lambda Functions ---

resource "aws_lambda_function" "this" {
  for_each = var.functions

  function_name = "${local.name_prefix}-${each.key}"
  description   = each.value.description
  role          = var.lambda_role_arn
  runtime       = each.value.runtime
  handler       = each.value.handler
  memory_size   = each.value.memory_size
  timeout       = each.value.timeout

  # Deploy from local zip or S3
  filename          = each.value.filename != "" ? each.value.filename : null
  s3_bucket         = each.value.s3_bucket != "" ? each.value.s3_bucket : null
  s3_key            = each.value.s3_key != "" ? each.value.s3_key : null
  s3_object_version = each.value.s3_object_version != "" ? each.value.s3_object_version : null

  # Hash triggers redeployment on code changes. For S3-based deploys, callers
  # should pass source_code_hash (e.g. the S3 object etag) explicitly.
  source_code_hash = coalesce(
    each.value.source_code_hash != "" ? each.value.source_code_hash : null,
    each.value.filename != "" ? filebase64sha256(each.value.filename) : null,
  )

  environment {
    variables = merge({
      ENVIRONMENT = var.environment
      PROJECT     = var.project
    }, each.value.environment_variables)
  }

  kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null

  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [each.value.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  reserved_concurrent_executions = each.value.reserved_concurrent_executions
  layers                         = each.value.layers

  tracing_config {
    mode = "Active"
  }

  dynamic "dead_letter_config" {
    for_each = var.enable_dlq ? [1] : []
    content {
      target_arn = aws_sns_topic.dlq[each.key].arn
    }
  }

  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-${each.key}"
    Function = each.key
  })
}

# DLQ topics -- only created when enable_dlq is true.
# Wire up subscriptions (email, SQS, etc.) outside this module.

resource "aws_sns_topic" "dlq" {
  for_each = var.enable_dlq ? var.functions : {}

  name = "${local.name_prefix}-${each.key}-dlq"

  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-${each.key}-dlq"
    Function = each.key
  })
}

# Log groups with explicit retention

resource "aws_cloudwatch_log_group" "lambda" {
  for_each = var.functions

  name              = "/aws/lambda/${local.name_prefix}-${each.key}"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-${each.key}-logs"
    Function = each.key
  })
}
