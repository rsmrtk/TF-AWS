locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Module = "iam"
  }
}
