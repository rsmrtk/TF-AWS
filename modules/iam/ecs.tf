################################################################################
# ECS Task Role
################################################################################

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

################################################################################
# ECS Execution Role
################################################################################

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

################################################################################
# ECS Custom Policy – Secrets Manager, KMS, and ECR Access
################################################################################

data "aws_iam_policy_document" "ecs_custom" {
  count = var.create_ecs_execution_role ? 1 : 0

  statement {
    sid    = "SecretsManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = ["*"]
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
