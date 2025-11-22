#!/bin/bash

set -euo pipefail

for cmd in gsutil terraform; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: ${cmd} is not installed"
        exit 1
    fi
done

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
TERRAFORM_DIR="${ROOT_DIR}/terraform"
ANSIBLE_DIR="${ROOT_DIR}/ansible"
INVENTORY_FILE="${ANSIBLE_DIR}/inventory/hosts.ini"

SPARK_TGZ_OVERRIDE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --spark-tgz=*)
            SPARK_TGZ_OVERRIDE="${1#*=}"
            shift
            ;;
        --spark-tgz)
            if [[ -n "${2:-}" ]]; then
                SPARK_TGZ_OVERRIDE="$2"
                shift 2
            else
                echo "Error: --spark-tgz requires a path argument"
                exit 1
            fi
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Error: Unknown argument $1"
            exit 1
            ;;
    esac
done

if [ ! -f "$INVENTORY_FILE" ]; then
    echo "Error: Inventory file not found at ${INVENTORY_FILE}. Run generate_inventory.sh first."
    exit 1
fi

get_var() {
    local key=$1
    local value
    value=$(awk -F'=' -v k="$key" '$1==k {print $2}' "$INVENTORY_FILE" | tr -d ' \t\r')
    echo "$value"
}

SPARK_VERSION=${SPARK_VERSION:-$(get_var "spark_version")}
HADOOP_VERSION=${HADOOP_VERSION:-$(get_var "hadoop_version")}

if [ -z "$SPARK_VERSION" ] || [ -z "$HADOOP_VERSION" ]; then
    echo "Error: Unable to determine Spark or Hadoop version from inventory. Set SPARK_VERSION/HADOOP_VERSION env vars."
    exit 1
fi

if [ -z "${SPARK_ARTIFACT_BUCKET:-}" ]; then
    if [ ! -d "$TERRAFORM_DIR" ]; then
        echo "Error: Terraform directory not found at ${TERRAFORM_DIR}"
        exit 1
    fi
    TERRAFORM_OUTPUTS_FILE="${TERRAFORM_DIR}/terraform_outputs.json"
    if [ -f "${TERRAFORM_OUTPUTS_FILE}" ]; then
        BUCKET_NAME=$(jq -r '.artifacts_bucket_name.value // empty' "${TERRAFORM_OUTPUTS_FILE}" 2>/dev/null || true)
    else
        BUCKET_NAME=""
    fi
    if [ -z "$BUCKET_NAME" ] || [ "$BUCKET_NAME" = "null" ]; then
        echo "Error: Unable to determine artifacts bucket from Terraform outputs. Set SPARK_ARTIFACT_BUCKET manually."
        exit 1
    fi
    SPARK_ARTIFACT_BUCKET="$BUCKET_NAME"
fi

if [ -n "$SPARK_TGZ_OVERRIDE" ]; then
    SPARK_TGZ="$SPARK_TGZ_OVERRIDE"
elif [ -n "${SPARK_TGZ_PATH:-}" ]; then
    SPARK_TGZ="$SPARK_TGZ_PATH"
else
    SPARK_TGZ=$(find "$ROOT_DIR" -maxdepth 3 -name "spark-*.tgz" | head -n 1 || true)
fi

if [ -z "$SPARK_TGZ" ]; then
    echo "Error: Spark tgz not found. Set SPARK_TGZ_PATH to override search."
    exit 1
fi

if [ ! -f "$SPARK_TGZ" ]; then
    echo "Error: Spark tgz path ${SPARK_TGZ} does not exist"
    exit 1
fi

DEST_URI="gs://${SPARK_ARTIFACT_BUCKET}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"

# === LOGIC CHECK FILE TỒN TẠI ===
echo "Checking if artifact exists at ${DEST_URI}..."
if gsutil -q stat "$DEST_URI"; then
    echo "✅ Artifact already exists at ${DEST_URI}. Skipping upload."
    exit 0
fi
# ================================

echo "Uploading ${SPARK_TGZ} to ${DEST_URI}..."
gsutil cp "$SPARK_TGZ" "$DEST_URI"
echo "Spark artifact uploaded to ${DEST_URI}"