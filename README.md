# Spark Cluster on GCP with Terraform & Ansible

This project automates the provisioning and configuration of an Apache Spark cluster on Google Cloud Platform (GCP). It leverages **Terraform** for infrastructure-as-code (IaC) to create Compute Engine instances and networking, and **Ansible** for configuration management to set up Spark (Master/Worker architecture) on those instances.

The project includes a complete workflow for deploying the cluster, running a sample MapReduce (WordCount) job, benchmarking performance, and destroying the infrastructure.

## Prerequisites

Before running the scripts, ensure you have the following installed and configured:

1.  **Terraform**: Download and install Terraform
2.  **Ansible**: Install Ansible
3.  **Google Cloud SDK (gcloud)**: Install and authenticate (`gcloud auth login`, `gcloud auth application-default login`).
4.  **jq**: Command-line JSON processor (used for parsing Terraform outputs).
    ```bash
    sudo apt-get install jq
    ```
5.  **SSH Key Pair**: The scripts assume a specific SSH key named `spark-cluster-key` exists for cluster access.
    ```bash
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/spark-cluster-key -N ""
    ```
6.  **GCP Credentials**: `gcp-credentials.json` to access your GCP project

7.  **Spark Distribution**: A Spark binary tarball (e.g., `spark-3.5.3-bin-hadoop3.tgz`) is required. The deployment script will upload this to a GCS bucket. You can place it in the project root or provide the path via command line.

## Project Structure

- `terraform/`: Terraform configuration files for GCP resources.
- `ansible/`: Ansible playbooks and roles for Spark configuration.
- `scripts/`: Automation scripts for the entire lifecycle.
    - `deploy.sh`: Deploys infrastructure and configures the cluster.
    - `submit_job.sh`: Submits a Spark job to the cluster.
    - `benchmark.sh`: Runs performance benchmarks.
    - `destroy.sh`: Destroys all provisioned resources.

## Quick Start

Follow these steps to deploy, test, and teardown the Spark cluster.

### 1. Deploy Cluster
Run the deployment script to provision resources with Terraform and configure them with Ansible. You can optionally provide the path to a Spark tarball if required by the upload script.

```bash
./scripts/deploy.sh
# Optional: ./scripts/deploy.sh --spark-tgz /path/to/spark-3.x.x-bin-hadoop3.tgz
```

### 2. Submit a Job
Submit the sample WordCount job to the cluster. This script connects to the edge/master node and submits the job using `spark-submit`.

```bash
./scripts/submit_job.sh
```
*Note: This script currently submits a job using the input file `filesample.txt` which is uploaded during deployment.*

### 3. Run Benchmark
Run the automated benchmark script. This will execute the Spark job with varying numbers of executors (1, 2, 4, 8) and generate a performance report.

```bash
./scripts/benchmark.sh
```
*This script executes the WordCount job with 1, 2, 4, and 8 executors to measure performance speedup.*

### 4. Clean Up
**Important:** After you are done, run the destroy script to remove all GCP resources and avoid unnecessary charges.

```bash
./scripts/destroy.sh
```