resource "aws_launch_template" "this" {
  name        = "${local.name_prefix}-app-lt"
  description = "Launch template for ${local.name_prefix} application instances"

  image_id      = local.use_custom_ami ? var.ami_id : data.aws_ami.amazon_linux_2023[0].id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  user_data = var.user_data != "" ? base64encode(var.user_data) : null

  dynamic "iam_instance_profile" {
    for_each = var.instance_profile_name != "" ? [1] : []
    content {
      name = var.instance_profile_name
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_security_group_id]
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.kms_key_arn != "" ? var.kms_key_arn : null
      delete_on_termination = true
    }
  }

  # IMDSv2 required -- prevents SSRF-based credential theft
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      local.common_tags,
      { Name = "${local.name_prefix}-app-instance" },
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      local.common_tags,
      { Name = "${local.name_prefix}-app-volume" },
    )
  }

  tags = merge(
    var.tags,
    local.common_tags,
    { Name = "${local.name_prefix}-app-lt" },
  )

  lifecycle {
    create_before_destroy = true
  }
}

# -- ASG with mixed instances (on-demand base + spot overflow) ----------------

resource "aws_autoscaling_group" "this" {
  name                = "${local.name_prefix}-app-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns         = [aws_lb_target_group.this.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.this.id
        version            = "$Latest"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
  }

  dynamic "tag" {
    for_each = merge(
      var.tags,
      local.common_tags,
      { Name = "${local.name_prefix}-app-instance" },
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  depends_on = [aws_lb.this]
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${local.name_prefix}-app-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = 70.0
    disable_scale_in = false
  }
}
