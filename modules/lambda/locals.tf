locals {
  name_prefix  = "${var.project}-${var.environment}"
  create_apigw = var.enable_api_gateway
  common_tags = merge(var.tags, {
    Module = "lambda"
  })
}
