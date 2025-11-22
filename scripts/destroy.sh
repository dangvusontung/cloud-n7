#!/bin/bash

set -euo pipefail

if ! command -v terraform &> /dev/null; then
    echo "Error: terraform is not installed"
    exit 1
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
TERRAFORM_DIR="${ROOT_DIR}/terraform"
HOSTS_INI_FILE="${ROOT_DIR}/ansible/inventory/hosts.ini"

if [ ! -d "$TERRAFORM_DIR" ]; then
    echo "Error: Terraform directory not found at ${TERRAFORM_DIR}"
    exit 1
fi

cd "$TERRAFORM_DIR"

echo "Destroying Terraform infrastructure..."
terraform destroy -auto-approve

echo "Terraform destroy completed successfully"

# Remove hosts.ini file if it exists
if [ -f "$HOSTS_INI_FILE" ]; then
    echo "Removing ${HOSTS_INI_FILE}..."
    rm -f "$HOSTS_INI_FILE"
    echo "hosts.ini file removed"
else
    echo "hosts.ini file not found, skipping removal"
fi

echo "Cleanup completed successfully"

