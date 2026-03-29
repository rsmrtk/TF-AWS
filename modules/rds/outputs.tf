output "db_instance_endpoint" {
  description = "Connection endpoint of the RDS instance."
  value       = local.is_aurora ? "" : try(aws_db_instance.this[0].endpoint, "")
}

output "db_instance_address" {
  description = "Hostname of the RDS instance."
  value       = local.is_aurora ? "" : try(aws_db_instance.this[0].address, "")
}

output "db_instance_port" {
  description = "Port of the RDS instance."
  value       = local.is_aurora ? "" : try(aws_db_instance.this[0].port, "")
}

output "db_instance_name" {
  description = "Name of the default database."
  value       = var.database_name
}

output "db_instance_id" {
  description = "Identifier of the RDS instance."
  value       = local.is_aurora ? "" : try(aws_db_instance.this[0].id, "")
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group."
  value       = aws_db_subnet_group.this.name
}
