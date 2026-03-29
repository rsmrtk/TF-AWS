#!/usr/bin/env bash
set -euo pipefail

# NOTE: Running with -backend=false for offline validation. Plans run against
# empty state, so resource counts will always show additions. For real plans,
# use `make plan ENV=<env>` with backend credentials configured.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
ENVS=("dev" "staging" "prod")
EXIT_CODE=0

for env in "${ENVS[@]}"; do
  echo "==> Planning ${env}..."
  cd "${ROOT_DIR}/environments/${env}"

  if terraform init -backend=false -input=false > /dev/null 2>&1; then
    if ! terraform plan -input=false; then
      echo "    ERROR: Plan failed for ${env}"
      EXIT_CODE=1
    fi
  else
    echo "    ERROR: Init failed for ${env}"
    EXIT_CODE=1
  fi

  cd "${ROOT_DIR}"
  echo ""
done

if [ "${EXIT_CODE}" -eq 0 ]; then
  echo "==> All plans completed successfully."
else
  echo "==> Some plans failed. Check output above."
fi

exit "${EXIT_CODE}"
