provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Project    = var.project
        ManagedBy  = "terraform"
        Component  = "global-iam"
        Repository = "${var.github_org}/${var.github_repo}"
      },
      var.tags,
    )
  }
}

# --------------------------------------------------------------------------
# GitHub Actions OIDC Provider
# --------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# --------------------------------------------------------------------------
# Plan role — read-only, used on PRs
# --------------------------------------------------------------------------
resource "aws_iam_role" "github_actions_plan" {
  name        = "${var.project}-github-actions-plan"
  description = "Role assumed by GitHub Actions for terraform plan (read-only)."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:pull_request"
          }
        }
      },
    ]
  })

  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "plan_read_only" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "plan_state_access" {
  name = "${var.project}-plan-state-access"
  role = aws_iam_role.github_actions_plan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = concat(
          [for arn in values(var.state_bucket_arns) : arn],
          [for arn in values(var.state_bucket_arns) : "${arn}/*"],
        )
      },
      {
        Sid    = "DynamoDBLockAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
        ]
        Resource = values(var.lock_table_arns)
      },
    ]
  })
}

# --------------------------------------------------------------------------
# Apply role — used on merge to main
# --------------------------------------------------------------------------
resource "aws_iam_role" "github_actions_apply" {
  name        = "${var.project}-github-actions-apply"
  description = "Role assumed by GitHub Actions for terraform apply."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
          }
        }
      },
    ]
  })

  max_session_duration = 7200
}

resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# --------------------------------------------------------------------------
# Terraform execution role (for local development)
# --------------------------------------------------------------------------
resource "aws_iam_role" "terraform_execution" {
  name        = "${var.project}-terraform-execution"
  description = "Role for local Terraform execution with broad permissions."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/Team" = "devops"
          }
        }
      },
    ]
  })

  max_session_duration = 7200
}

resource "aws_iam_role_policy_attachment" "execution_admin" {
  role       = aws_iam_role.terraform_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
