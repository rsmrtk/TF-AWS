################################################################################
# Lambda Execution Role
################################################################################

data "aws_iam_policy_document" "lambda_assume_role" {
  count = var.create_lambda_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  count = var.create_lambda_role ? 1 : 0

  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role[0].json

  tags = merge(local.common_tags, var.tags)
}

################################################################################
# Lambda Managed Policy Attachments
################################################################################

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count = var.create_lambda_role ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = var.create_lambda_role ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

################################################################################
# Lambda Custom Policy – S3 and KMS Access
################################################################################

data "aws_iam_policy_document" "lambda_custom" {
  count = var.create_lambda_role && (length(var.s3_bucket_arns) > 0 || var.kms_key_arn != "") ? 1 : 0

  dynamic "statement" {
    for_each = length(var.s3_bucket_arns) > 0 ? [1] : []

    content {
      sid    = "S3Access"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:DeleteObject",
      ]
      resources = flatten([
        var.s3_bucket_arns,
        [for arn in var.s3_bucket_arns : "${arn}/*"],
      ])
    }
  }

  dynamic "statement" {
    for_each = var.kms_key_arn != "" ? [1] : []

    content {
      sid    = "KMSAccess"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey",
      ]
      resources = [var.kms_key_arn]
    }
  }
}

resource "aws_iam_role_policy" "lambda_custom" {
  count = var.create_lambda_role && (length(var.s3_bucket_arns) > 0 || var.kms_key_arn != "") ? 1 : 0

  name   = "${local.name_prefix}-lambda-custom-policy"
  role   = aws_iam_role.lambda[0].id
  policy = data.aws_iam_policy_document.lambda_custom[0].json
}
