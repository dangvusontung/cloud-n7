#!/bin/bash

set -euo pipefail

if ! command -v terraform &> /dev/null; then
    echo "Error: terraform is not installed"
    exit 1
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
TERRAFORM_DIR="${ROOT_DIR}/terraform"

if [ ! -d "$TERRAFORM_DIR" ]; then
    echo "Error: Terraform directory not found at ${TERRAFORM_DIR}"
    exit 1
fi

cd "$TERRAFORM_DIR"

terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# Save terraform outputs to a file for use by other scripts
TERRAFORM_OUTPUTS_FILE="${TERRAFORM_DIR}/terraform_outputs.json"
echo "Saving terraform outputs to ${TERRAFORM_OUTPUTS_FILE}..."
terraform output -json > "${TERRAFORM_OUTPUTS_FILE}"

if [ ! -f "${TERRAFORM_OUTPUTS_FILE}" ]; then
    echo "Warning: Failed to save terraform outputs file"
    exit 1
fi

echo "Terraform deployment completed successfully"
echo "Terraform outputs saved to ${TERRAFORM_OUTPUTS_FILE}"

