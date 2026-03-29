locals {
  name_prefix = "${var.project}-${var.environment}"
  is_s3       = var.origin_type == "s3"
  common_tags = {
    Module = "cloudfront"
  }
}
