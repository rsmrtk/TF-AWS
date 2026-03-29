output "state_bucket_ids" {
  description = "Map of environment name to S3 state bucket ID."
  value       = { for k, v in aws_s3_bucket.terraform_state : k => v.id }
}

output "state_bucket_arns" {
  description = "Map of environment name to S3 state bucket ARN."
  value       = { for k, v in aws_s3_bucket.terraform_state : k => v.arn }
}

output "lock_table_names" {
  description = "Map of environment name to DynamoDB lock table name."
  value       = { for k, v in aws_dynamodb_table.terraform_locks : k => v.name }
}

output "lock_table_arns" {
  description = "Map of environment name to DynamoDB lock table ARN."
  value       = { for k, v in aws_dynamodb_table.terraform_locks : k => v.arn }
}
