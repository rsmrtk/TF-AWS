################################################################################
# Lambda Functions
################################################################################

resource "aws_lambda_function" "this" {
  for_each = var.functions

  function_name = "${local.name_prefix}-${each.key}"
  description   = each.value.description
  role          = var.lambda_role_arn
  runtime       = each.value.runtime
  handler       = each.value.handler
  memory_size   = each.value.memory_size
  timeout       = each.value.timeout

  # Source code: local file or S3
  filename         = each.value.filename != "" ? each.value.filename : null
  source_code_hash = each.value.filename != "" ? filebase64sha256(each.value.filename) : null
  s3_bucket        = each.value.s3_bucket != "" ? each.value.s3_bucket : null
  s3_key           = each.value.s3_key != "" ? each.value.s3_key : null

  # Environment variables merged with defaults
  environment {
    variables = merge(
      {
        ENVIRONMENT = var.environment
        PROJECT     = var.project
      },
      each.value.environment_variables
    )
  }

  # KMS encryption for environment variables
  kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null

  # VPC configuration (conditional)
  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [each.value.vpc_config] : []

    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Concurrency
  reserved_concurrent_executions = each.value.reserved_concurrent_executions

  # Layers
  layers = each.value.layers

  # X-Ray tracing
  tracing_config {
    mode = "Active"
  }

  # Dead letter config (optional SNS topic)
  dynamic "dead_letter_config" {
    for_each = try(aws_sns_topic.dlq[each.key], null) != null ? [1] : []

    content {
      target_arn = aws_sns_topic.dlq[each.key].arn
    }
  }

  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-${each.key}"
    Function = each.key
  })
}

################################################################################
# Dead Letter Queue (SNS Topic per function)
################################################################################

resource "aws_sns_topic" "dlq" {
  for_each = var.functions

  name = "${local.name_prefix}-${each.key}-dlq"

  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-${each.key}-dlq"
    Function = each.key
  })
}

################################################################################
# CloudWatch Log Groups
################################################################################

resource "aws_cloudwatch_log_group" "lambda" {
  for_each = var.functions

  name              = "/aws/lambda/${local.name_prefix}-${each.key}"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name     = "${local.name_prefix}-${each.key}-logs"
    Function = each.key
  })
}
