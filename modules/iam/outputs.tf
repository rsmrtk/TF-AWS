# EC2

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role."
  value       = try(aws_iam_role.ec2[0].arn, null)
}

output "ec2_role_name" {
  description = "Name of the EC2 IAM role."
  value       = try(aws_iam_role.ec2[0].name, null)
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile."
  value       = try(aws_iam_instance_profile.ec2[0].name, null)
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile."
  value       = try(aws_iam_instance_profile.ec2[0].arn, null)
}

# ECS

output "ecs_task_role_arn" {
  description = "ARN of the ECS task IAM role."
  value       = try(aws_iam_role.ecs_task[0].arn, null)
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution IAM role."
  value       = try(aws_iam_role.ecs_execution[0].arn, null)
}

# Lambda

output "lambda_role_arn" {
  description = "ARN of the Lambda execution IAM role."
  value       = try(aws_iam_role.lambda[0].arn, null)
}

output "lambda_role_name" {
  description = "Name of the Lambda execution IAM role."
  value       = try(aws_iam_role.lambda[0].name, null)
}
