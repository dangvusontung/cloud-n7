#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

SPARK_TGZ_ARG=""
ANSIBLE_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --spark-tgz=*)
            SPARK_TGZ_ARG="${1#*=}"
            shift
            ;;
        --spark-tgz)
            if [[ -n "${2:-}" ]]; then
                SPARK_TGZ_ARG="$2"
                shift 2
            else
                echo "Error: --spark-tgz requires a path argument"
                exit 1
            fi
            ;;
        --)
            shift
            ANSIBLE_ARGS+=("$@")
            break
            ;;
        *)
            ANSIBLE_ARGS+=("$1")
            shift
            ;;
    esac
done

UPLOAD_ARGS=()
if [[ -n "$SPARK_TGZ_ARG" ]]; then
    UPLOAD_ARGS+=(--spark-tgz "$SPARK_TGZ_ARG")
fi

"${SCRIPT_DIR}/run_terraform.sh"
"${SCRIPT_DIR}/generate_inventory.sh"
"${SCRIPT_DIR}/upsize.sh"
"${SCRIPT_DIR}/upload_spark_artifact.sh" "${UPLOAD_ARGS[@]}"
echo "Terraform and upload completed successfully, waiting for 10 seconds before running ansible..."
sleep 10 
"${SCRIPT_DIR}/run_ansible.sh" "${ANSIBLE_ARGS[@]}"