# Networking
output "vpc_id" {
  description = "VPC ID."
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.networking.private_subnet_ids
}

# Compute
output "alb_dns_name" {
  description = "ALB DNS name."
  value       = module.compute.alb_dns_name
}

# EKS
output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

# RDS
output "rds_endpoint" {
  description = "RDS endpoint."
  value       = module.rds.db_instance_endpoint
}

output "rds_secret_arn" {
  description = "RDS credentials secret ARN."
  value       = module.rds.db_secret_arn
}

# ECR
output "ecr_repository_urls" {
  description = "ECR repository URLs."
  value       = module.ecr.repository_urls
}

# CloudFront
# Uncomment when the CloudFront module is enabled.
# output "cloudfront_distribution_domain" {
#   description = "CloudFront distribution domain name."
#   value       = module.cloudfront.distribution_domain_name
# }

# Monitoring
output "monitoring_sns_topic_arn" {
  description = "SNS topic ARN for monitoring alarms."
  value       = module.monitoring.sns_topic_arn
}
