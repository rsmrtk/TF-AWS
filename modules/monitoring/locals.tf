locals {
  name_prefix = "${var.project}-${var.environment}"
  create_sns  = length(var.alarm_email_endpoints) > 0

  common_tags = {
    Module = "monitoring"
  }
}
