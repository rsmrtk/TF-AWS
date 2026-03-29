locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  common_tags = {
    Project     = var.project
    Environment = var.environment
  }
}
