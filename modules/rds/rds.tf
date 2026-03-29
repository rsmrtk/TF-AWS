################################################################################
# RDS Instance (non-Aurora)
################################################################################

resource "aws_db_instance" "this" {
  count = local.is_aurora ? 0 : 1

  identifier = "${local.name_prefix}-db-instance"

  # Engine
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn != "" ? var.kms_key_arn : null

  # Networking
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  # Authentication
  db_name  = var.database_name
  username = var.master_username
  password = random_password.master.result

  # Parameter group
  parameter_group_name = aws_db_parameter_group.this[0].name

  # Backup
  backup_retention_period   = var.backup_retention_period
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:30-sun:05:30"
  copy_tags_to_snapshot     = true
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-db-final-snapshot"

  # High availability
  multi_az = var.multi_az

  # Performance insights
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_enabled && var.kms_key_arn != "" ? var.kms_key_arn : null

  # Enhanced monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.enhanced_monitoring[0].arn : null

  # Protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  # Upgrades
  auto_minor_version_upgrade = true

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-db-instance"
    },
  )

  lifecycle {
    precondition {
      condition     = var.environment != "prod" || var.multi_az
      error_message = "Production environments must have multi_az enabled."
    }
  }
}
