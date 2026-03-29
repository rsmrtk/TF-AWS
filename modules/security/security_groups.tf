################################################################################
# ALB Security Group
################################################################################

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb-sg"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from anywhere"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-alb-http-ingress" })
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS from anywhere"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-alb-https-ingress" })
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-alb-egress" })
}

################################################################################
# Application Security Group
################################################################################

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Security group for application instances"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-app-sg"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  for_each = toset([for p in var.app_ports : tostring(p)])

  security_group_id            = aws_security_group.app.id
  description                  = "Allow traffic from ALB on port ${each.value}"
  from_port                    = tonumber(each.value)
  to_port                      = tonumber(each.value)
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-app-alb-ingress-${each.value}" })
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-app-egress" })
}

################################################################################
# Database Security Group
################################################################################

resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "Security group for database instances"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-db-sg"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_postgresql" {
  security_group_id            = aws_security_group.db.id
  description                  = "Allow PostgreSQL from application security group"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.app.id

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-db-postgresql-ingress" })
}

resource "aws_vpc_security_group_ingress_rule" "db_mysql" {
  security_group_id            = aws_security_group.db.id
  description                  = "Allow MySQL from application security group"
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.app.id

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-db-mysql-ingress" })
}

resource "aws_vpc_security_group_egress_rule" "db_all" {
  security_group_id = aws_security_group.db.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-db-egress" })
}

################################################################################
# Bastion Security Group
################################################################################

resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-bastion-sg"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  for_each = toset(var.bastion_allowed_cidrs)

  security_group_id = aws_security_group.bastion.id
  description       = "Allow SSH from ${each.value}"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-bastion-ssh-ingress" })
}

resource "aws_vpc_security_group_egress_rule" "bastion_all" {
  security_group_id = aws_security_group.bastion.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-bastion-egress" })
}
