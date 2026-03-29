output "github_actions_plan_role_arn" {
  description = "ARN of the IAM role for GitHub Actions plan."
  value       = aws_iam_role.github_actions_plan.arn
}

output "github_actions_apply_role_arn" {
  description = "ARN of the IAM role for GitHub Actions apply."
  value       = aws_iam_role.github_actions_apply.arn
}

output "terraform_execution_role_arn" {
  description = "ARN of the IAM role for local Terraform execution."
  value       = aws_iam_role.terraform_execution.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github_actions.arn
}
