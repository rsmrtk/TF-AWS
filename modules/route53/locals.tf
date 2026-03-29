locals {
  name_prefix = "${var.project}-${var.environment}"
  zone_id     = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id

  common_tags = {
    Module = "route53"
  }
}
