resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, var.tags)
}

# Capacity provider strategy: one on-demand task guaranteed (base=1),
# remaining tasks split between on-demand and spot according to the
# configured weight. Adjust var.spot_capacity_weight per environment.
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 100 - var.spot_capacity_weight
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = var.spot_capacity_weight
  }
}
