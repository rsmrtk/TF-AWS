output "cluster_id" {
  description = "ID of the ECS cluster."
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = aws_ecs_cluster.this.arn
}

output "service_names" {
  description = "Map of service keys to their ECS service names."
  value = {
    for k, v in aws_ecs_service.services : k => v.name
  }
}

output "task_definition_arns" {
  description = "Map of service keys to their latest task definition ARNs."
  value = {
    for k, v in aws_ecs_task_definition.services : k => v.arn
  }
}
