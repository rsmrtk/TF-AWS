# ECS Module

Manages AWS ECS Fargate clusters, services, and task definitions.

This module creates an ECS cluster with Container Insights enabled, configures FARGATE and FARGATE\_SPOT capacity providers, and provisions per-service CloudWatch log groups, task definitions, and ECS services. Load balancer integration is conditional on providing a target group ARN per service.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
