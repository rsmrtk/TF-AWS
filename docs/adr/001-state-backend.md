# ADR 001: State Backend

## Status

Accepted

## Context

Terraform state must be stored remotely to enable team collaboration, state locking, and disaster recovery. Options considered:

1. **S3 + DynamoDB** — native AWS backend
2. **Terraform Cloud** — managed service
3. **Consul** — HashiCorp's KV store

## Decision

Use S3 + DynamoDB per environment for state storage and locking.

## Rationale

- Native AWS integration with no additional service dependencies
- Per-environment isolation prevents accidental cross-environment state corruption
- S3 versioning enables state history and rollback
- DynamoDB provides reliable distributed locking
- Cost-effective at any scale (PAY_PER_REQUEST billing)
- Encryption at rest via SSE-KMS

## Consequences

- Must bootstrap state backend before any environment deployment
- State bucket names must be globally unique
- DynamoDB tables are region-specific
