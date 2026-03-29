# Backend Bootstrap

Provisions the S3 buckets and DynamoDB tables used for Terraform remote state and locking.

## Usage

```bash
cd global/backend-bootstrap
terraform init
terraform apply
```

> **Note:** This must be applied before any other environment. State for this module is stored locally.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
