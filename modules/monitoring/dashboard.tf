################################################################################
# CloudWatch Dashboard
################################################################################

resource "aws_cloudwatch_dashboard" "this" {
  count = length(var.dashboard_widgets) > 0 ? 1 : 0

  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      for i, widget in var.dashboard_widgets : {
        type   = widget.type
        x      = (i % 2) * 12
        y      = floor(i / 2) * 6
        width  = 12
        height = 6
        properties = {
          title   = widget.title
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          period  = widget.period
          stat    = widget.stat
          metrics = [
            flatten([
              widget.namespace,
              widget.metric_name,
              [for k, v in widget.dimensions : [k, v]]
            ])
          ]
        }
      }
    ]
  })
}

data "aws_region" "current" {}
