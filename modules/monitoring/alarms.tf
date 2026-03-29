################################################################################
# CloudWatch Metric Alarms
################################################################################

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.alarms

  alarm_name          = "${local.name_prefix}-${each.key}"
  alarm_description   = each.value.description
  namespace           = each.value.namespace
  metric_name         = each.value.metric_name
  comparison_operator = each.value.comparison_operator
  threshold           = each.value.threshold
  evaluation_periods  = each.value.evaluation_periods
  period              = each.value.period
  statistic           = each.value.statistic
  dimensions          = each.value.dimensions
  treat_missing_data  = each.value.treat_missing_data

  alarm_actions = local.create_sns ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions    = local.create_sns ? [aws_sns_topic.alarms[0].arn] : []

  tags = merge(local.common_tags, var.tags, {
    Name = "${local.name_prefix}-${each.key}"
  })
}
