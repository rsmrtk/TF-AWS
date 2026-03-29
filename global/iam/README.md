# Global IAM

Provisions IAM roles for Terraform execution:

- **GitHub Actions OIDC Provider** — federated identity for keyless CI/CD
- **Plan Role** — read-only, scoped to pull request events
- **Apply Role** — admin, scoped to main branch pushes
- **Execution Role** — for local development with team-based access control

## Usage

```bash
cd global/iam
terraform init
terraform apply
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
