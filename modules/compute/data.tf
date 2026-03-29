###############################################################################
# Latest Amazon Linux 2023 AMI
# Used only when var.ami_id is empty.
###############################################################################

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

###############################################################################
# Current AWS caller identity & region (for S3 bucket naming, etc.)
###############################################################################

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_elb_service_account" "current" {}
