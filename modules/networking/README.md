# Networking Module

Reusable Terraform module for AWS networking infrastructure. Provisions a VPC with
public, private, and data subnet tiers across multiple availability zones, NAT and
Internet gateways, VPC endpoints for common AWS services, and optional VPC flow logs.

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  project     = "myapp"
  environment = "prod"
  vpc_cidr    = "10.0.0.0/16"
  azs         = ["us-east-1a", "us-east-1b", "us-east-1c"]

  single_nat_gateway   = false
  enable_vpc_endpoints = true
  enable_flow_logs     = true

  tags = {
    Team = "platform"
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
