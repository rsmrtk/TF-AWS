locals {
  name_prefix    = "${var.project}-${var.environment}"
  use_custom_ami = var.ami_id != ""

  common_tags = {
    Module = "compute"
  }
}
