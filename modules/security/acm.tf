################################################################################
# ACM Certificate
################################################################################

resource "aws_acm_certificate" "this" {
  count = local.create_acm ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-acm-cert"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}
