# --- API Gateway v2 (HTTP API) ---

resource "aws_apigatewayv2_api" "this" {
  count = local.create_apigw ? 1 : 0

  name          = var.api_gateway_name != "" ? var.api_gateway_name : "${local.name_prefix}-api"
  protocol_type = "HTTP"

  # Only set CORS when origins are explicitly configured
  dynamic "cors_configuration" {
    for_each = length(var.cors_allowed_origins) > 0 ? [1] : []
    content {
      allow_origins = var.cors_allowed_origins
      allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
      allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key"]
      max_age       = 3600
    }
  }

  tags = merge(local.common_tags, {
    Name = var.api_gateway_name != "" ? var.api_gateway_name : "${local.name_prefix}-api"
  })
}

# Default stage -- auto-deploys on every change

resource "aws_apigatewayv2_stage" "default" {
  count = local.create_apigw ? 1 : 0

  api_id      = aws_apigatewayv2_api.this[0].id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
    format = jsonencode({
      requestId        = "$context.requestId"
      ip               = "$context.identity.sourceIp"
      requestTime      = "$context.requestTime"
      httpMethod       = "$context.httpMethod"
      routeKey         = "$context.routeKey"
      status           = "$context.status"
      protocol         = "$context.protocol"
      responseLength   = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-default-stage"
  })
}

# One integration per function

resource "aws_apigatewayv2_integration" "this" {
  for_each = local.create_apigw ? var.functions : {}

  api_id                 = aws_apigatewayv2_api.this[0].id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.this[each.key].invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Routes: ANY /{function_name}/{proxy+}

resource "aws_apigatewayv2_route" "this" {
  for_each = local.create_apigw ? var.functions : {}

  api_id             = aws_apigatewayv2_api.this[0].id
  route_key          = "ANY /${each.key}/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
  authorization_type = var.api_authorization_type
}

# Allow API Gateway to invoke each function

resource "aws_lambda_permission" "api_gateway" {
  for_each = local.create_apigw ? var.functions : {}

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this[0].execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  count = local.create_apigw ? 1 : 0

  name              = "/aws/apigateway/${var.api_gateway_name != "" ? var.api_gateway_name : "${local.name_prefix}-api"}"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-api-gateway-logs"
  })
}
