locals {
  name_prefix = "${var.project}-${var.environment}"
  is_aurora   = startswith(var.engine, "aurora-")
  common_tags = {
    Module = "rds"
  }
}
