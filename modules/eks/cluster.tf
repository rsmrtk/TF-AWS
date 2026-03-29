# -- Cluster IAM role ----------------------------------------------------------

resource "aws_iam_role" "cluster" {
  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, var.tags)
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_security_group" "cluster" {
  name        = "${local.name_prefix}-eks-cluster-sg"
  description = "Security group for the EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    var.tags,
    { Name = "${local.name_prefix}-eks-cluster-sg" },
  )
}

resource "aws_security_group_rule" "cluster_egress" {
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
}

# -- EKS cluster --------------------------------------------------------------

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_public_access  = var.cluster_endpoint_public_access
    endpoint_private_access = var.cluster_endpoint_private_access
    security_group_ids      = [aws_security_group.cluster.id]
  }

  # API_AND_CONFIG_MAP keeps the aws-auth ConfigMap working while also
  # enabling the newer EKS access entry API for future migration.
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  enabled_cluster_log_types = var.cluster_log_types

  dynamic "encryption_config" {
    for_each = var.enable_cluster_encryption && var.kms_key_arn != "" ? [1] : []

    content {
      provider {
        key_arn = var.kms_key_arn
      }
      resources = ["secrets"]
    }
  }

  tags = merge(local.common_tags, var.tags)

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
  ]
}

# -- Addons -------------------------------------------------------------------
# service_account_role_arn is set for the EBS CSI driver so the IRSA role
# created in irsa.tf is actually used. Without this the addon falls back to
# the node role which may lack the required permissions.

resource "aws_eks_addon" "this" {
  for_each = var.cluster_addons

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = (
    each.key == "aws-ebs-csi-driver"
    ? aws_iam_role.ebs_csi_driver.arn
    : null
  )

  tags = merge(local.common_tags, var.tags)

  depends_on = [
    aws_eks_node_group.this,
  ]
}
