################################################################################
# EC2 IAM Role and Instance Profile
################################################################################

data "aws_iam_policy_document" "ec2_assume_role" {
  count = var.create_ec2_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  count = var.create_ec2_role ? 1 : 0

  name               = "${local.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role[0].json

  tags = merge(local.common_tags, var.tags)
}

resource "aws_iam_instance_profile" "ec2" {
  count = var.create_ec2_role ? 1 : 0

  name = "${local.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2[0].name

  tags = merge(local.common_tags, var.tags)
}

################################################################################
# EC2 Managed Policy Attachments
################################################################################

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  count = var.create_ec2_role ? 1 : 0

  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  count = var.create_ec2_role ? 1 : 0

  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

################################################################################
# EC2 Custom S3 Access Policy
################################################################################

data "aws_iam_policy_document" "ec2_s3_access" {
  count = var.create_ec2_role && length(var.s3_bucket_arns) > 0 ? 1 : 0

  statement {
    sid    = "S3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject",
    ]
    resources = flatten([
      var.s3_bucket_arns,
      [for arn in var.s3_bucket_arns : "${arn}/*"],
    ])
  }
}

resource "aws_iam_role_policy" "ec2_s3_access" {
  count = var.create_ec2_role && length(var.s3_bucket_arns) > 0 ? 1 : 0

  name   = "${local.name_prefix}-ec2-s3-access-policy"
  role   = aws_iam_role.ec2[0].id
  policy = data.aws_iam_policy_document.ec2_s3_access[0].json
}
