################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    },
  )
}

################################################################################
# NAT Gateway(s)
################################################################################

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-eip-${var.azs[count.index]}"
    },
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-${var.azs[count.index]}"
    },
  )

  depends_on = [aws_internet_gateway.this]
}
