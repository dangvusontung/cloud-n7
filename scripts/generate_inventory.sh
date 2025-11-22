#!/bin/bash

set -euo pipefail

for cmd in jq terraform; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: ${cmd} is not installed"
        exit 1
    fi
done

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
TERRAFORM_DIR="${ROOT_DIR}/terraform"
ANSIBLE_DIR="${ROOT_DIR}/ansible"
INVENTORY_TEMPLATE="${ANSIBLE_DIR}/inventory/hosts.ini.template"
INVENTORY_OUTPUT="${ANSIBLE_DIR}/inventory/hosts.ini"

if [ ! -d "$TERRAFORM_DIR" ]; then
    echo "Error: Terraform directory not found at ${TERRAFORM_DIR}"
    exit 1
fi

if [ ! -d "$ANSIBLE_DIR" ]; then
    echo "Error: Ansible directory not found at ${ANSIBLE_DIR}"
    exit 1
fi

if [ ! -f "$INVENTORY_TEMPLATE" ]; then
    echo "Error: Inventory template not found at ${INVENTORY_TEMPLATE}"
    exit 1
fi

TERRAFORM_OUTPUTS_FILE="${TERRAFORM_DIR}/terraform_outputs.json"

# Check if terraform outputs file exists
if [ ! -f "${TERRAFORM_OUTPUTS_FILE}" ]; then
    echo "Error: Terraform outputs file not found at ${TERRAFORM_OUTPUTS_FILE}"
    echo "Please run terraform apply first"
    exit 1
fi

MASTER_EXTERNAL_IP=$(jq -r '.master_external_ip.value' "${TERRAFORM_OUTPUTS_FILE}")
MASTER_INTERNAL_IP=$(jq -r '.master_internal_ip.value' "${TERRAFORM_OUTPUTS_FILE}")
EDGE_EXTERNAL_IP=$(jq -r '.edge_external_ip.value' "${TERRAFORM_OUTPUTS_FILE}")
EDGE_INTERNAL_IP=$(jq -r '.edge_internal_ip.value' "${TERRAFORM_OUTPUTS_FILE}")
mapfile -t WORKER_EXT_IPS < <(jq -r '.worker_external_ips.value[]' "${TERRAFORM_OUTPUTS_FILE}")
mapfile -t WORKER_INT_IPS < <(jq -r '.worker_internal_ips.value[]' "${TERRAFORM_OUTPUTS_FILE}")

if [ "${#WORKER_EXT_IPS[@]}" -eq 0 ]; then
    echo "Error: No worker nodes found in Terraform outputs"
    exit 1
fi

if [ "${#WORKER_EXT_IPS[@]}" -ne "${#WORKER_INT_IPS[@]}" ]; then
    echo "Error: Worker IP arrays differ in length"
    exit 1
fi

WORKER_BLOCK=""
for i in "${!WORKER_EXT_IPS[@]}"; do
    index=$((i + 1))
    line="spark-worker-${index} ansible_host=${WORKER_EXT_IPS[$i]} ansible_user=sparkuser private_ip=${WORKER_INT_IPS[$i]}"
    if [ -z "$WORKER_BLOCK" ]; then
        WORKER_BLOCK="${line}"
    else
        WORKER_BLOCK="${WORKER_BLOCK}"$'\n'"${line}"
    fi
done

cd "$ANSIBLE_DIR"
cp "$INVENTORY_TEMPLATE" "$INVENTORY_OUTPUT"

sed -i \
    -e "s/<MASTER_IP>/${MASTER_EXTERNAL_IP}/g" \
    -e "s/<MASTER_PRIVATE_IP>/${MASTER_INTERNAL_IP}/g" \
    -e "s/<EDGE_IP>/${EDGE_EXTERNAL_IP}/g" \
    -e "s/<EDGE_PRIVATE_IP>/${EDGE_INTERNAL_IP}/g" \
    "$INVENTORY_OUTPUT"

TMP_FILE=$(mktemp)
awk -v block="$WORKER_BLOCK" '
{
    if ($0 == "__WORKERS_BLOCK__") {
        print block;
        next;
    }
    print $0;
}
' "$INVENTORY_OUTPUT" > "$TMP_FILE"
mv "$TMP_FILE" "$INVENTORY_OUTPUT"

WORKER_COUNT=${#WORKER_EXT_IPS[@]}
echo "Inventory file created at ${INVENTORY_OUTPUT}"
echo "Master: ${MASTER_EXTERNAL_IP} (${MASTER_INTERNAL_IP})"
echo "Workers: ${WORKER_COUNT}"
echo "Edge: ${EDGE_EXTERNAL_IP} (${EDGE_INTERNAL_IP})"

