output "vpc_id" {
  description = "ID of the VPC created by the networking module."
  value       = module.networking.vpc_id
}

output "rds_endpoint" {
  description = "Connection endpoint for the RDS instance."
  value       = module.rds.db_instance_endpoint
}
