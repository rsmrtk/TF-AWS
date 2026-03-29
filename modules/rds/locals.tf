locals {
  name_prefix = "${var.project}-${var.environment}"

  # e.g. "postgres16" or "mysql8.0" -- callers can override via var.parameter_group_family
  pg_family = var.parameter_group_family != "" ? var.parameter_group_family : "${var.engine}${split(".", var.engine_version)[0]}"

  common_tags = {
    Module = "rds"
  }
}
