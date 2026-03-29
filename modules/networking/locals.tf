locals {
  name_prefix = "${var.project}-${var.environment}"

  az_count = length(var.azs)

  # Dynamic subnet calculation using cidrsubnet
  public_subnets  = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnets = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 100)]
  data_subnets    = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 200)]

  nat_gateway_count = var.single_nat_gateway ? 1 : local.az_count

  common_tags = {
    Module = "networking"
  }
}
