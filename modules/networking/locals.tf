locals {
  name_prefix = "${var.project}-${var.environment}"

  az_count = length(var.azs)

  # Subnet CIDR allocation: public at /24 offset 0+, private at 100+, data at 200+
  public_subnets  = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnets = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 100)]
  data_subnets    = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 200)]

  nat_gateway_count = var.single_nat_gateway ? 1 : local.az_count

  common_tags = {
    Module = "networking"
  }

  # Interface endpoints provisioned when enable_vpc_endpoints is true
  interface_endpoints = {
    ecr_api = {
      service_name = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
      name_suffix  = "ecr-api-endpoint"
    }
    ecr_dkr = {
      service_name = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
      name_suffix  = "ecr-dkr-endpoint"
    }
    logs = {
      service_name = "com.amazonaws.${data.aws_region.current.name}.logs"
      name_suffix  = "logs-endpoint"
    }
    sts = {
      service_name = "com.amazonaws.${data.aws_region.current.name}.sts"
      name_suffix  = "sts-endpoint"
    }
    ssm = {
      service_name = "com.amazonaws.${data.aws_region.current.name}.ssm"
      name_suffix  = "ssm-endpoint"
    }
  }
}
