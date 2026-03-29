# --- Subnet Group ---

resource "aws_db_subnet_group" "this" {
  name        = "${local.name_prefix}-db-subnet-group"
  description = "DB subnet group for ${local.name_prefix}"
  subnet_ids  = var.data_subnet_ids

  tags = merge(var.tags, local.common_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}

# --- Parameter Group ---

resource "aws_db_parameter_group" "this" {
  name        = "${local.name_prefix}-db-parameter-group"
  family      = local.pg_family
  description = "Parameter group for ${local.name_prefix}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, local.common_tags, {
    Name = "${local.name_prefix}-db-parameter-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# --- Master password (stored in Secrets Manager) ---

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%^&*()-_=+[]{}|:,.<>?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${local.name_prefix}-db-credentials"
  description = "Database credentials for ${local.name_prefix}"
  kms_key_id  = var.kms_key_arn != "" ? var.kms_key_arn : null

  tags = merge(var.tags, local.common_tags, {
    Name = "${local.name_prefix}-db-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
    engine   = var.engine
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.database_name
  })
}
