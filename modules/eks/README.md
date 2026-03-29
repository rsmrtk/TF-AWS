# EKS Module

Terraform module for managing an Amazon EKS cluster with managed node groups, cluster addons, and IAM Roles for Service Accounts (IRSA).

## Features

- EKS cluster with configurable Kubernetes version and endpoint access
- Managed node groups with flexible instance types, scaling, labels, and taints
- Cluster addons (vpc-cni, coredns, kube-proxy, aws-ebs-csi-driver)
- OIDC provider for IAM Roles for Service Accounts (IRSA)
- Optional envelope encryption for Kubernetes secrets via KMS
- Control plane logging

## Usage

```hcl
module "eks" {
  source = "./modules/eks"

  project            = "myapp"
  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_version = "1.30"

  node_groups = {
    general = {
      instance_types = ["m6i.large"]
      min_size       = 2
      max_size       = 5
      desired_size   = 3
    }
  }

  tags = {
    Team = "platform"
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
