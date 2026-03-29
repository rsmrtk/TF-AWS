output "zone_id" {
  description = "The ID of the Route53 hosted zone (created or provided)."
  value       = local.zone_id
}

output "zone_name_servers" {
  description = "Name servers for the hosted zone. Only populated when the zone is created by this module."
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : []
}

output "record_fqdns" {
  description = "Map of record keys to their fully qualified domain names."
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
}

output "health_check_ids" {
  description = "Map of health check keys to their IDs."
  value       = { for k, v in aws_route53_health_check.this : k => v.id }
}
