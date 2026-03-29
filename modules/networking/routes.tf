# Public route table -- single table, all public subnets share it
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-rt"
    },
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route tables -- NAT egress for workload subnets
resource "aws_route_table" "private" {
  count = local.nat_gateway_count

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-rt-${var.azs[count.index]}"
    },
  )
}

resource "aws_route" "private_nat" {
  count = local.nat_gateway_count

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count = local.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

# Data route table -- isolated, local-only (no NAT, no internet)
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-data-rt"
    },
  )
}

resource "aws_route_table_association" "data" {
  count = local.az_count

  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data.id
}
