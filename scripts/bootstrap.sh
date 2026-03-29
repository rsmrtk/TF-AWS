#!/usr/bin/env bash
set -euo pipefail

# Bootstrap the Terraform state backend.
# Run this once before deploying any environment.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${SCRIPT_DIR}/../global/backend-bootstrap"

echo "==> Bootstrapping Terraform state backend..."
cd "${BOOTSTRAP_DIR}"

terraform init
terraform plan -out=tfplan
terraform apply tfplan
rm -f tfplan

echo "==> State backend bootstrapped successfully."
echo "    You can now initialize environments with: make init ENV=dev"
