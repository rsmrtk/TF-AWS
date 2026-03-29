################################################################################
# VPC
################################################################################

output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

################################################################################
# Subnets
################################################################################

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "data_subnet_ids" {
  description = "List of data subnet IDs."
  value       = aws_subnet.data[*].id
}

################################################################################
# Gateways
################################################################################

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs."
  value       = aws_nat_gateway.this[*].id
}

output "igw_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

################################################################################
# VPC Endpoints
################################################################################

output "vpc_endpoint_s3_id" {
  description = "The ID of the S3 VPC gateway endpoint."
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}

output "vpc_endpoint_sg_id" {
  description = "The ID of the security group for VPC interface endpoints."
  value       = try(aws_security_group.vpc_endpoints[0].id, null)
}
