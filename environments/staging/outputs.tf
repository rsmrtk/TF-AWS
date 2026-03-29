################################################################################
# Networking
################################################################################

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC."
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = module.networking.private_subnet_ids
}

output "data_subnet_ids" {
  description = "List of data subnet IDs."
  value       = module.networking.data_subnet_ids
}

################################################################################
# Security
################################################################################

output "kms_key_arn" {
  description = "ARN of the KMS key."
  value       = module.security.kms_key_arn
}

output "alb_security_group_id" {
  description = "ID of the ALB security group."
  value       = module.security.alb_security_group_id
}

output "app_security_group_id" {
  description = "ID of the application security group."
  value       = module.security.app_security_group_id
}

output "db_security_group_id" {
  description = "ID of the database security group."
  value       = module.security.db_security_group_id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF web ACL."
  value       = module.security.waf_web_acl_arn
}

################################################################################
# IAM
################################################################################

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile."
  value       = module.iam.ec2_instance_profile_name
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role."
  value       = module.iam.ecs_task_role_arn
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role."
  value       = module.iam.ecs_execution_role_arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role."
  value       = module.iam.lambda_role_arn
}

################################################################################
# S3
################################################################################

output "s3_bucket_ids" {
  description = "Map of S3 bucket IDs."
  value       = module.s3.bucket_ids
}

output "s3_bucket_arns" {
  description = "Map of S3 bucket ARNs."
  value       = module.s3.bucket_arns
}

################################################################################
# ECR
################################################################################

output "ecr_repository_urls" {
  description = "Map of ECR repository URLs."
  value       = module.ecr.repository_urls
}

################################################################################
# Compute
################################################################################

output "alb_dns_name" {
  description = "DNS name of the ALB."
  value       = module.compute.alb_dns_name
}

output "asg_name" {
  description = "Name of the Auto Scaling Group."
  value       = module.compute.asg_name
}

################################################################################
# EKS
################################################################################

output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster."
  value       = module.eks.cluster_version
}

output "eks_oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider."
  value       = module.eks.oidc_provider_arn
}

################################################################################
# ECS
################################################################################

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = module.ecs.cluster_arn
}

################################################################################
# RDS
################################################################################

output "rds_endpoint" {
  description = "Endpoint of the RDS instance."
  value       = module.rds.db_instance_endpoint
}

output "rds_secret_arn" {
  description = "ARN of the database credentials secret."
  value       = module.rds.db_secret_arn
}

################################################################################
# Monitoring
################################################################################

output "sns_topic_arn" {
  description = "ARN of the monitoring SNS topic."
  value       = module.monitoring.sns_topic_arn
}
