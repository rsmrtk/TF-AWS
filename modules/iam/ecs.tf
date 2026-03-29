# ECS task role -- used by application containers at runtime.

data "aws_iam_policy_document" "ecs_task_assume_role" {
  count = var.create_ecs_task_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  count = var.create_ecs_task_role ? 1 : 0

  name               = "${local.name_prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role[0].json

  tags = merge(local.common_tags, var.tags)
}

# Attach caller-supplied policies to the task role (e.g. SQS, DynamoDB, etc.)
resource "aws_iam_role_policy_attachment" "ecs_task_extra" {
  for_each = var.create_ecs_task_role ? toset(var.ecs_task_role_policy_arns) : toset([])

  role       = aws_iam_role.ecs_task[0].name
  policy_arn = each.value
}

# ECS execution role -- used by the ECS agent to pull images and fetch secrets.

data "aws_iam_policy_document" "ecs_execution_assume_role" {
  count = var.create_ecs_execution_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  count = var.create_ecs_execution_role ? 1 : 0

  name               = "${local.name_prefix}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_assume_role[0].json

  tags = merge(local.common_tags, var.tags)
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  count = var.create_ecs_execution_role ? 1 : 0

  role       = aws_iam_role.ecs_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Scoped-down policy for secrets, KMS, and ECR access.

data "aws_iam_policy_document" "ecs_custom" {
  count = var.create_ecs_execution_role ? 1 : 0

  # Scope secrets access to this project/env instead of "*"
  statement {
    sid    = "SecretsManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = ["arn:aws:secretsmanager:*:*:secret:${var.project}-${var.environment}-*"]
  }

  dynamic "statement" {
    for_each = var.kms_key_arn != "" ? [1] : []

    content {
      sid    = "KMSDecrypt"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
      ]
      resources = [var.kms_key_arn]
    }
  }

  # ECR auth token is account-wide; image pulls are covered by the managed policy.
  statement {
    sid    = "ECRAccess"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_custom" {
  count = var.create_ecs_execution_role ? 1 : 0

  name   = "${local.name_prefix}-ecs-execution-custom-policy"
  role   = aws_iam_role.ecs_execution[0].id
  policy = data.aws_iam_policy_document.ecs_custom[0].json
}
