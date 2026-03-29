# --- ALB ---

resource "aws_security_group" "alb" {
  name_prefix = "${local.name_prefix}-alb-sg-"
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

# --- Application ---

resource "aws_security_group" "app" {
  name_prefix = "${local.name_prefix}-app-sg-"
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

# --- Database ---
# Egress intentionally omitted: the DB should not initiate outbound connections.
# If replication or external calls are needed, add specific rules.

resource "aws_security_group" "db" {
  name_prefix = "${local.name_prefix}-db-sg-"
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

# Single ingress rule driven by var.db_port -- no more opening both MySQL and PG.
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Allow DB traffic from application SG on port ${var.db_port}"
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.app.id

  tags = merge(var.tags, local.common_tags, { Name = "${local.name_prefix}-db-ingress" })
}

# --- Bastion ---

resource "aws_security_group" "bastion" {
  name_prefix = "${local.name_prefix}-bastion-sg-"
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
