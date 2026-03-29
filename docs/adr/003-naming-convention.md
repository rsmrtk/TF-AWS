# ADR 003: Naming Convention

## Status

Accepted

## Context

Consistent resource naming is critical for:
- Resource identification and ownership
- Automation and scripting
- Cost allocation and billing
- Security and compliance auditing

## Decision

All resources follow the pattern: `${project}-${environment}-${service}-${resource}`

Examples:
- VPC: `tfaws-prod-networking-vpc`
- ALB: `tfaws-staging-compute-alb`
- RDS: `tfaws-dev-rds-instance`
- S3: `tfaws-prod-assets` (bucket names are globally unique)

## Rationale

- Immediately identifies project, environment, and purpose
- Supports tag-based filtering and IAM policies
- Compatible with AWS resource name length limits
- Enables predictable resource discovery

## Consequences

- All modules must accept `project` and `environment` as inputs
- Naming validation enforced via variable validation blocks
- Long service names may need abbreviation
