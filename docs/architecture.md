# Architecture

## Overview

This repository implements a production-grade AWS infrastructure using Terraform with a module-composition pattern. Each environment (dev, staging, prod) composes reusable child modules with environment-specific configurations.

## Design Principles

1. **Module Composition** — Reusable modules in `modules/` are composed by environment configurations in `environments/`
2. **State Isolation** — Each environment has its own S3 backend and DynamoDB lock table
3. **Least Privilege** — OIDC-based authentication for CI/CD, scoped IAM roles
4. **Encryption by Default** — KMS CMK for all data at rest, TLS enforced
5. **Progressive Delivery** — Sequential deployment: dev → staging → prod

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                   │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Public AZ-a │  │  Public AZ-b │  │  Public AZ-c │     │
│  │  10.0.0.0/24 │  │  10.0.1.0/24 │  │  10.0.2.0/24 │     │
│  │  ALB, NAT GW │  │  ALB, NAT GW │  │  ALB, NAT GW │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│  ┌──────┴───────┐  ┌──────┴───────┐  ┌──────┴───────┐     │
│  │ Private AZ-a │  │ Private AZ-b │  │ Private AZ-c │     │
│  │ 10.0.100/24  │  │ 10.0.101/24  │  │ 10.0.102/24  │     │
│  │ EKS, ECS, EC2│  │ EKS, ECS, EC2│  │ EKS, ECS, EC2│     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│  ┌──────┴───────┐  ┌──────┴───────┐  ┌──────┴───────┐     │
│  │  Data AZ-a   │  │  Data AZ-b   │  │  Data AZ-c   │     │
│  │ 10.0.200/24  │  │ 10.0.201/24  │  │ 10.0.202/24  │     │
│  │  RDS, Cache  │  │  RDS, Cache  │  │  RDS, Cache  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                             │
│  VPC Endpoints: S3, DynamoDB, ECR, Logs, STS, SSM          │
└─────────────────────────────────────────────────────────────┘
```

## Module Dependency Graph

```
environments/{env}/main.tf
├── modules/networking    (VPC, subnets, NAT, endpoints)
├── modules/security      (KMS, SGs, WAF, ACM)
│   └── depends on: networking
├── modules/iam           (roles, policies, profiles)
│   └── depends on: security
├── modules/s3            (buckets, encryption, lifecycle)
│   └── depends on: security
├── modules/ecr           (repositories, scanning)
│   └── depends on: security
├── modules/compute       (ALB, ASG, launch templates)
│   └── depends on: networking, security, iam
├── modules/eks           (cluster, node groups, IRSA)
│   └── depends on: networking, security
├── modules/ecs           (Fargate cluster, services)
│   └── depends on: networking, security, iam
├── modules/rds           (database, parameter groups)
│   └── depends on: networking, security
├── modules/lambda        (functions, API Gateway)
│   └── depends on: iam, security
├── modules/cloudfront    (CDN, OAC)
│   └── depends on: s3, security
├── modules/route53       (DNS, health checks)
└── modules/monitoring    (alarms, dashboards, SNS)
```

## Environment Sizing

| Resource | Dev | Staging | Prod |
|---|---|---|---|
| AZs | 2 | 3 | 3 |
| NAT Gateways | 1 | 1 | 3 (per AZ) |
| EKS Nodes | 1x t3.medium | 2x t3.large | 3x m5.xlarge |
| RDS | db.t3.micro, single-AZ | db.t3.medium, single-AZ | db.r5.large, multi-AZ |
| Backup Retention | 7 days | 14 days | 35 days |
| WAF | Disabled | Count mode | Block mode |
| Deletion Protection | Off | On (RDS) | On (all) |

## CI/CD Pipeline

```
Push to feature branch
  └── terraform-validate.yml (fmt, validate, tflint, checkov)

Pull Request to main
  └── terraform-plan.yml (plan for all envs, post to PR)

Merge to main
  └── terraform-apply.yml (dev → staging → prod, sequential)

Weekday schedule
  └── drift-detection.yml (plan -detailed-exitcode, create issue on drift)
```

## State Management

- **Backend**: S3 with versioning and encryption
- **Locking**: DynamoDB with PAY_PER_REQUEST billing
- **Isolation**: One bucket + table per environment
- **Bootstrap**: `global/backend-bootstrap/` must be applied first
