################################################################################
# KMS
################################################################################

output "kms_key_id" {
  description = "ID of the general-purpose KMS key."
  value       = aws_kms_key.general.key_id
}

output "kms_key_arn" {
  description = "ARN of the general-purpose KMS key."
  value       = aws_kms_key.general.arn
}

output "kms_alias_arn" {
  description = "ARN of the KMS key alias."
  value       = aws_kms_alias.general.arn
}

################################################################################
# Security Groups
################################################################################

output "alb_security_group_id" {
  description = "ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "ID of the application security group."
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "ID of the database security group."
  value       = aws_security_group.db.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group."
  value       = aws_security_group.bastion.id
}

################################################################################
# WAF
################################################################################

output "waf_web_acl_arn" {
  description = "ARN of the WAF v2 web ACL. Empty string when WAF is not enabled."
  value       = try(aws_wafv2_web_acl.this[0].arn, "")
}

################################################################################
# ACM
################################################################################

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate. Empty string when no domain name is provided."
  value       = try(aws_acm_certificate.this[0].arn, "")
}
