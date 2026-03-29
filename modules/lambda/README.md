# Lambda Module

Terraform module for managing AWS Lambda functions, layers, and API Gateway v2 (HTTP API) integration.

This module creates Lambda functions with X-Ray tracing, dead letter queues (SNS), CloudWatch log groups, and optionally provisions an API Gateway HTTP API with per-function routes.

## Naming Convention

All resources follow the naming pattern: `${project}-${environment}-{service}-{resource}`

## Features

- Lambda functions with configurable runtime, memory, timeout, and concurrency
- Local file or S3-based deployment packages
- Optional VPC configuration per function
- KMS encryption for environment variables
- X-Ray active tracing enabled by default
- SNS dead letter queue per function
- CloudWatch log groups with 14-day retention
- Optional API Gateway v2 (HTTP API) with auto-deploy stage
- Per-function API Gateway integrations and routes

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
