data "aws_caller_identity" "current" {}

# ---- SNS Topic for alarm fanout ----

resource "aws_sns_topic" "alarms" {
  count = local.create_sns ? 1 : 0

  name              = "${local.name_prefix}-alarms"
  kms_master_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = merge(local.common_tags, var.tags, {
    Name = "${local.name_prefix}-alarms"
  })
}

# Restrict publishing to CloudWatch from *this* account only.
# Without the SourceAccount condition any account could publish if they
# guess the topic ARN.
data "aws_iam_policy_document" "sns_topic_policy" {
  count = local.create_sns ? 1 : 0

  statement {
    sid    = "AllowCloudWatchPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.alarms[0].arn]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sns_topic_policy" "alarms" {
  count = local.create_sns ? 1 : 0

  arn    = aws_sns_topic.alarms[0].arn
  policy = data.aws_iam_policy_document.sns_topic_policy[0].json
}

# Email subscriptions -- these require manual confirmation via the inbox.
resource "aws_sns_topic_subscription" "email" {
  for_each = local.create_sns ? toset(var.alarm_email_endpoints) : toset([])

  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = each.value
}
