#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TERRAFORM_DIR="${ROOT_DIR}/terraform"
TERRAFORM_OUTPUTS_FILE="${TERRAFORM_DIR}/terraform_outputs.json"

echo "Fetching IP from Terraform outputs file..."
if [ ! -d "$TERRAFORM_DIR" ]; then
    echo "Error: Terraform directory not found!"
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

SSH_USER="sparkuser"
SSH_KEY="~/.ssh/spark-cluster-key"
MASTER_URL="spark://${MASTER_IP}:7077"
JAR_PATH="/opt/spark-apps/wordcount.jar"

INPUT_FILE="/tmp/filesample.txt"
REPORT_FILE="${SCRIPT_DIR}/benchmark_reportreport.txt"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSH_KEY"

echo "Target: Edge ($EDGE_IP) | Master ($MASTER_IP)"
echo "Saving report to: $REPORT_FILE"
echo "---------------------------------------------"

echo "Executors | Time (ms) | Speedup (approx)" > "$REPORT_FILE"
echo "----------|-----------|-----------------" >> "$REPORT_FILE"

EXECUTOR_COUNTS=(1 2 4 8)
BASE_TIME=0

for exec_num in "${EXECUTOR_COUNTS[@]}"; do
    echo -n "Running with $exec_num executors... "
    
    TIMESTAMP=$(date +%s)
    OUTPUT_DIR="/tmp/bench_out_${exec_num}ex_${TIMESTAMP}"

    TIME_MS=$(ssh $SSH_OPTS ${SSH_USER}@${EDGE_IP} "
        /opt/spark/bin/spark-submit \
        --class WordCount \
        --master $MASTER_URL \
        --deploy-mode client \
        --executor-memory 512m \
        --num-executors $exec_num \
        $JAR_PATH $INPUT_FILE $OUTPUT_DIR 2>&1 \
        | grep 'time in ms' | awk -F ':' '{print \$2}' | tr -d ' '
    ")

    if [ -z "$TIME_MS" ]; then
        echo "FAILED (Check logs on Edge)"
        TIME_MS="N/A"
    else
        echo "Done in ${TIME_MS}ms"
        
        if [ "$exec_num" -eq 1 ]; then
            BASE_TIME=$TIME_MS
            SPEEDUP="1.0x"
        else
            if [ "$TIME_MS" -gt 0 ]; then
                SPEEDUP=$(echo "scale=2; $BASE_TIME / $TIME_MS" | bc)x
            else
                SPEEDUP="Error"
            fi
        fi

        echo "$exec_num         | $TIME_MS      | $SPEEDUP" >> "$REPORT_FILE"
    fi
    
    sleep 5
done

echo "---------------------------------------------"
echo "BENCHMARK COMPLETED!"
echo "Detailed results:"
cat "$REPORT_FILE"