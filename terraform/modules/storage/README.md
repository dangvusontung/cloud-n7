# Storage Module

This module creates GCS buckets for the Spark cluster:

1. **Data Bucket**: For storing input/output data files
2. **Event Logs Bucket**: For Spark event logs (used by History Server)
3. **Artifacts Bucket**: For storing application JARs, Python files, and dependencies

## Features

- Uniform bucket-level access enabled
- IAM bindings for service account
- Lifecycle rules for automatic cleanup
- Versioning on data and artifacts buckets
- Proper labeling for resource management

## Usage

The buckets are automatically created when you run `terraform apply`. After deployment, you can use them in Spark:

```bash
# Upload data to GCS
gsutil cp input.txt gs://<data-bucket-name>/input/

# Submit Spark job using GCS paths
spark-submit \
  --master spark://<master-ip>:7077 \
  wordcount.py \
  gs://<data-bucket-name>/input/input.txt \
  gs://<data-bucket-name>/output/result

# Configure Spark to use GCS for event logs
# In spark-defaults.conf:
spark.eventLog.dir gs://<event-logs-bucket-name>/eventLogs
```

## Bucket Naming

Buckets are named using the pattern: `<project-id>-<cluster-name>-<purpose>`

Example: `my-project-spark-data`, `my-project-spark-event-logs`, `my-project-spark-artifacts`

## IAM Permissions

The service account used by VMs is granted `roles/storage.objectAdmin` on all buckets, allowing:
- Read/write access to objects
- List bucket contents
- Delete objects (within retention policy)

## Lifecycle Management

- **Data bucket**: Objects older than 90 days are automatically deleted (configurable)
- **Event logs bucket**: Objects older than 30 days are automatically deleted (configurable)
- **Artifacts bucket**: No automatic deletion (versioning enabled for safety)

