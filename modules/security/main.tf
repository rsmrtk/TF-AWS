locals {
  name_prefix = "${var.project}-${var.environment}"
  create_acm  = var.domain_name != ""
  create_waf  = var.enable_waf

  common_tags = {
    Module = "security"
  }
}
