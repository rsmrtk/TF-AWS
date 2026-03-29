# ---- Hosted Zone ----

resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0

  name = var.zone_name

  lifecycle {
    precondition {
      condition     = var.zone_name != ""
      error_message = "zone_name must be provided when creating a hosted zone."
    }
  }

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-zone"
    },
  )
}

# ---- DNS Records ----

resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = local.zone_id
  name    = each.key
  type    = each.value.type

  # Standard records need an explicit TTL; alias records get it from the target.
  ttl     = each.value.alias == null ? each.value.ttl : null
  records = each.value.alias == null ? each.value.records : null

  # Attach the health check when the caller provides a matching key.
  health_check_id = (
    each.value.health_check_key != null
    ? aws_route53_health_check.this[each.value.health_check_key].id
    : null
  )

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []

    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }
}

# ---- Health Checks ----

resource "aws_route53_health_check" "this" {
  for_each = var.health_checks

  fqdn              = each.value.fqdn
  port              = each.value.port
  type              = each.value.type
  resource_path     = each.value.resource_path
  failure_threshold = each.value.failure_threshold
  request_interval  = each.value.request_interval

  tags = merge(
    var.tags,
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.key}-health-check"
    },
  )
}
