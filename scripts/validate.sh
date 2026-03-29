#!/usr/bin/env bash
set -euo pipefail

# Validate all Terraform configurations.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
ENVS=("dev" "staging" "prod")
EXIT_CODE=0

echo "==> Checking formatting..."
if ! terraform fmt -check -recursive "${ROOT_DIR}"; then
  echo "    ERROR: Formatting check failed. Run: terraform fmt -recursive"
  EXIT_CODE=1
fi

for env in "${ENVS[@]}"; do
  echo "==> Validating ${env}..."
  cd "${ROOT_DIR}/environments/${env}"

  if terraform init -backend=false -input=false > /dev/null 2>&1; then
    if ! terraform validate; then
      echo "    ERROR: Validation failed for ${env}"
      EXIT_CODE=1
    else
      echo "    OK: ${env} is valid."
    fi
  else
    echo "    ERROR: Init failed for ${env}"
    EXIT_CODE=1
  fi

  cd "${ROOT_DIR}"
done

if [ "${EXIT_CODE}" -eq 0 ]; then
  echo "==> All validations passed."
else
  echo "==> Some validations failed. Check output above."
fi

exit "${EXIT_CODE}"
