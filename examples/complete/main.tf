# Complete Example
#
# This example demonstrates how to use all modules together.
# Copy this to a new environment directory and customize the values.

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Project     = "example"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  project     = "example"
  environment = "dev"
  azs         = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "networking" {
  source = "../../modules/networking"

  project            = local.project
  environment        = local.environment
  vpc_cidr           = "10.0.0.0/16"
  azs                = local.azs
  single_nat_gateway = true
}

module "security" {
  source = "../../modules/security"

  project     = local.project
  environment = local.environment
  vpc_id      = module.networking.vpc_id
  vpc_cidr    = module.networking.vpc_cidr
}

module "iam" {
  source = "../../modules/iam"

  project     = local.project
  environment = local.environment
  kms_key_arn = module.security.kms_key_arn
}

module "rds" {
  source = "../../modules/rds"

  project              = local.project
  environment          = local.environment
  vpc_id               = module.networking.vpc_id
  data_subnet_ids      = module.networking.data_subnet_ids
  db_security_group_id = module.security.db_security_group_id
  instance_class       = "db.t3.micro"
  kms_key_arn          = module.security.kms_key_arn
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}
