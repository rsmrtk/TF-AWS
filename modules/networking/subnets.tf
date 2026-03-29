################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "public" {
  count = local.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name                     = "${local.name_prefix}-public-${var.azs[count.index]}"
      Tier                     = "public"
      "kubernetes.io/role/elb" = "1"
    },
  )
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name                              = "${local.name_prefix}-private-${var.azs[count.index]}"
      Tier                              = "private"
      "kubernetes.io/role/internal-elb" = "1"
    },
  )
}

################################################################################
# Data Subnets
################################################################################

resource "aws_subnet" "data" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.data_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-data-${var.azs[count.index]}"
      Tier = "data"
    },
  )
}
