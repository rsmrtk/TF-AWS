locals {
  name_prefix    = "${var.project}-${var.environment}"
  use_custom_ami = var.ami_id != ""

  common_tags = {
    Module = "compute"
  }
}

# Falls back to the latest AL2023 AMI when no custom AMI is supplied.
data "aws_ami" "amazon_linux_2023" {
  count = local.use_custom_ami ? 0 : 1

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "current" {}
