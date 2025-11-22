#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"
TERRAFORM_OUTPUTS_FILE="${TERRAFORM_DIR}/terraform_outputs.json"

if [ ! -d "$TERRAFORM_DIR" ]; then
    echo "Error: Terraform directory not found."
    exit 1
fi

if [ ! -f "${TERRAFORM_OUTPUTS_FILE}" ]; then
    echo "Error: Terraform outputs file not found at ${TERRAFORM_OUTPUTS_FILE}"
    echo "Please run terraform apply first"
    exit 1
fi

TF_OUT=$(cat "${TERRAFORM_OUTPUTS_FILE}")
EDGE_IP=$(echo "$TF_OUT" | jq -r '.edge_external_ip.value')
MASTER_IP=$(echo "$TF_OUT" | jq -r '.master_internal_ip.value')
EDGE_USER="sparkuser"
SSH_KEY="~/.ssh/spark-cluster-key"

MASTER_URL="spark://${MASTER_IP}:7077"
JAR_PATH="/opt/spark-apps/wordcount.jar"
INPUT_FILE="/tmp/filesample.txt"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="/tmp/output_${TIMESTAMP}"
EXECUTORS=${1:-2}

echo "Target: $EDGE_USER@$EDGE_IP"
echo "Job:    WordCount ($EXECUTORS executors)"

ssh -i ${SSH_KEY} ${EDGE_USER}@${EDGE_IP} << EOF
    set -e
    echo "Remote executing on Edge Node..."
    
    /opt/spark/bin/spark-submit \
    --class WordCount \
    --master ${MASTER_URL} \
    --deploy-mode client \
    --executor-memory 512m \
    --num-executors ${EXECUTORS} \
    ${JAR_PATH} \
    ${INPUT_FILE} \
    ${OUTPUT_DIR}
    
    echo "Done. Output: ${OUTPUT_DIR}"
EOF

