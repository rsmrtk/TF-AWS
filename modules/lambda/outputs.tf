output "function_arns" {
  description = "Map of function keys to ARNs."
  value = {
    for key, fn in aws_lambda_function.this : key => fn.arn
  }
}

output "function_names" {
  description = "Map of function keys to full function names."
  value = {
    for key, fn in aws_lambda_function.this : key => fn.function_name
  }
}

output "function_invoke_arns" {
  description = "Map of function keys to invoke ARNs."
  value = {
    for key, fn in aws_lambda_function.this : key => fn.invoke_arn
  }
}

output "dlq_topic_arns" {
  description = "Map of function keys to their DLQ SNS topic ARNs (empty when DLQ is disabled)."
  value = {
    for key, topic in aws_sns_topic.dlq : key => topic.arn
  }
}

# API Gateway

output "api_gateway_endpoint" {
  description = "API Gateway endpoint URL. Null when API Gateway is disabled."
  value       = local.create_apigw ? aws_apigatewayv2_api.this[0].api_endpoint : null
}

output "api_gateway_id" {
  description = "API Gateway ID. Null when API Gateway is disabled."
  value       = local.create_apigw ? aws_apigatewayv2_api.this[0].id : null
}
