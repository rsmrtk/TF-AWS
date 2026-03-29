output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications."
  value       = local.create_sns ? aws_sns_topic.alarms[0].arn : null
}

output "alarm_arns" {
  description = "Map of alarm names to their ARNs."
  value = {
    for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn
  }
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard."
  value       = length(var.dashboard_widgets) > 0 ? aws_cloudwatch_dashboard.this[0].dashboard_name : null
}
