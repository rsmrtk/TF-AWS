################################################################################
# Data source for current AWS region
################################################################################

data "aws_region" "current" {}

################################################################################
# VPC Endpoint Security Group
################################################################################

resource "aws_security_group" "vpc_endpoints" {
  count = var.enable_vpc_endpoints ? 1 : 0

  name        = "${local.name_prefix}-vpc-endpoints-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc-endpoints-sg"
    },
  )
}

################################################################################
# Gateway Endpoints
################################################################################

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    aws_route_table.data[*].id,
  )

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-s3-endpoint"
    },
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    aws_route_table.data[*].id,
  )

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-dynamodb-endpoint"
    },
  )
}

################################################################################
# Interface Endpoints
################################################################################

locals {
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

resource "aws_vpc_endpoint" "interface" {
  for_each = var.enable_vpc_endpoints ? local.interface_endpoints : {}

  vpc_id              = aws_vpc.this.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints[0].id]

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.value.name_suffix}"
    },
  )
}
