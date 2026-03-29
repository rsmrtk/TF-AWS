# TF-AWS: Production-Grade Terraform AWS Infrastructure

Production-ready, multi-environment AWS infrastructure managed with Terraform. Demonstrates reusable modules, CI/CD with OIDC authentication, security best practices, and progressive deployment.

## Architecture

```
TF-AWS/
├── global/                  # One-time setup (state backend, CI/CD IAM)
├── modules/                 # 13 reusable Terraform modules
│   ├── networking/          # VPC, subnets, NAT, VPC endpoints, flow logs
│   ├── security/            # KMS, security groups, WAF, ACM
│   ├── iam/                 # Roles, policies, instance profiles
│   ├── s3/                  # Buckets with encryption, lifecycle, TLS enforcement
│   ├── ecr/                 # Container registries with scanning, lifecycle
│   ├── compute/             # EC2, ASG, launch templates, ALB
│   ├── eks/                 # EKS cluster, managed node groups, IRSA
│   ├── ecs/                 # ECS Fargate, services, task definitions
│   ├── rds/                 # RDS/Aurora, parameter groups, Secrets Manager
│   ├── lambda/              # Functions, layers, API Gateway v2
│   ├── cloudfront/          # Distributions, OAC, cache policies
│   ├── route53/             # Hosted zones, records, health checks
│   └── monitoring/          # CloudWatch alarms, dashboards, SNS
├── environments/            # Environment-specific compositions
│   ├── dev/                 # Minimal: single NAT, t3.micro, no HA
│   ├── staging/             # Medium: mirrors prod topology
│   └── prod/                # Full HA: multi-AZ, m5.xlarge, deletion protection
├── .github/workflows/       # CI/CD pipelines
├── docs/                    # Architecture docs and ADRs
├── scripts/                 # Helper scripts
└── examples/                # Usage examples
```

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.9.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [TFLint](https://github.com/terraform-linters/tflint) (optional, for linting)
- [Checkov](https://www.checkov.io/) (optional, for security scanning)

### 1. Bootstrap State Backend

```bash
cd global/backend-bootstrap
terraform init
terraform apply
```

### 2. Deploy an Environment

```bash
make init ENV=dev
make plan ENV=dev
make apply ENV=dev
```

### 3. Validate All Configurations

```bash
make fmt-check
make validate-all
make lint
make security
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

## CI/CD Pipeline

| Trigger | Workflow | Action |
|---|---|---|
| Every push | `terraform-validate.yml` | Format, validate, lint, security scan |
| Pull request | `terraform-plan.yml` | Plan all envs, post to PR comment |
| Merge to main | `terraform-apply.yml` | Sequential apply: dev → staging → prod |
| Weekday schedule | `drift-detection.yml` | Detect drift, create GitHub issue |

Authentication uses **GitHub Actions OIDC** — no long-lived AWS credentials.

## Key Design Patterns

- **Module composition** — environments compose reusable child modules
- **Variable validation** — all inputs validated with custom rules
- **Lifecycle preconditions** — e.g., prod RDS must be multi-AZ
- **Dynamic subnet calculation** — `cidrsubnet()` for automatic CIDR allocation
- **KMS encryption** — CMK for all data at rest
- **TLS enforcement** — S3 bucket policies deny non-HTTPS requests
- **OIDC authentication** — keyless CI/CD via federated identity
- **Drift detection** — scheduled workflow with automated issue creation

## Makefile Commands

```
make help          # Show all commands
make init          # Initialize Terraform (ENV=dev)
make plan          # Run plan (ENV=dev)
make apply         # Apply plan (ENV=dev)
make destroy       # Destroy infrastructure (ENV=dev)
make fmt           # Format all files
make validate-all  # Validate all environments
make lint          # Run TFLint
make security      # Run Checkov
make docs          # Generate module documentation
make clean         # Remove .terraform and plans
```

## Documentation

- [Architecture Overview](docs/architecture.md)
- ADRs:
  - [001 - State Backend](docs/adr/001-state-backend.md)
  - [002 - Module Structure](docs/adr/002-module-structure.md)
  - [003 - Naming Convention](docs/adr/003-naming-convention.md)

## License

[MIT](LICENSE)
