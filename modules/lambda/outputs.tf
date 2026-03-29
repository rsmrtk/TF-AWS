################################################################################
# Lambda Function Outputs
################################################################################

output "function_arns" {
  description = "Map of Lambda function names to their ARNs"
  value = {
    for key, fn in aws_lambda_function.this : key => fn.arn
  }
}

output "function_names" {
  description = "Map of Lambda function keys to their full function names"
  value = {
    for key, fn in aws_lambda_function.this : key => fn.function_name
  }
}

output "function_invoke_arns" {
  description = "Map of Lambda function keys to their invoke ARNs"
  value = {
    for key, fn in aws_lambda_function.this : key => fn.invoke_arn
  }
}

################################################################################
# API Gateway Outputs
################################################################################

output "api_gateway_endpoint" {
  description = "The API Gateway endpoint URL (only available when API Gateway is enabled)"
  value       = local.create_apigw ? aws_apigatewayv2_api.this[0].api_endpoint : null
}

output "api_gateway_id" {
  description = "The API Gateway ID (only available when API Gateway is enabled)"
  value       = local.create_apigw ? aws_apigatewayv2_api.this[0].id : null
}
