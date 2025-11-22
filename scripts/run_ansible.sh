#!/bin/bash

set -euo pipefail

if ! command -v ansible-playbook &> /dev/null; then
    echo "Error: ansible-playbook is not installed"
    exit 1
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
ANSIBLE_DIR="${ROOT_DIR}/ansible"

if [ ! -d "$ANSIBLE_DIR" ]; then
    echo "Error: Ansible directory not found at ${ANSIBLE_DIR}"
    exit 1
fi

cd "$ANSIBLE_DIR"
echo "Running Ansible playbook..."

ansible-playbook playbook.yml -v "$@"
echo "Ansible playbook completed successfully"

