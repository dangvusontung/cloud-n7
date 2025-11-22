# Automated Spark Cluster Deployment and Benchmarking Report

## 1. Introduction

This report summarizes the architecture, methodology, and testing results of an automated Apache Spark cluster deployment on Google Cloud Platform (GCP). The project aims to demonstrate a fully automated Infrastructure-as-Code (IaC) workflow using Terraform for resource provisioning and Ansible for configuration management. The system's performance was validated using a standard WordCount benchmark job.

## 2. Architecture

The solution leverages a decoupled architecture where infrastructure provisioning is separated from software configuration.

### 2.1 Cloud Infrastructure (GCP)
The underlying infrastructure is hosted on Google Cloud Platform, provisioned via Terraform.

*   **Networking**:
    *   **VPC**: A dedicated Virtual Private Cloud (`spark-vpc`) ensures network isolation.
    *   **Subnet**: A specific subnet (`spark-subnet`, `10.0.1.0/24`) hosts all cluster nodes.
    *   **Firewall Rules**: Configured to allow internal cluster communication (Spark ports 7077, 8080, etc.) and restricted SSH access.

*   **Compute Resources**:
    The cluster consists of `e2-micro` instances organized into three distinct roles:
    1.  **Master Node (1)**: The central coordinator of the Spark cluster. It runs the Spark Master service which is responsible for resource negotiation, scheduling applications, and monitoring the health of worker nodes.
    2.  **Worker Nodes (3)**: The compute units of the cluster. Each worker runs a Spark Worker process that manages resources on the machine and spawns Executor processes to run the actual tasks (computations) assigned by the Master.
    3.  **Edge Node (1)**: The secure gateway for user interaction. It is the only node with a public IP exposed for SSH (though restricted). Users log in here to compile code, submit jobs (`spark-submit`), and view results. This prevents direct user access to the sensitive Master and Worker nodes, enhancing security.

*   **Storage**:
    *   **GCS Buckets**: Used for storing build artifacts (Spark binaries) and log data, ensuring persistence beyond the cluster lifecycle.

### 2.2 Software Stack
*   **Operating System**: Linux (Debian/Ubuntu based).
*   **Core Engine**: Apache Spark 2.4.3 (bundled with Hadoop 2.7).
*   **Runtime**: OpenJDK 8.
*   **Orchestration**: Ansible is used to idempotently install dependencies, configure Spark `spark-env.sh`, and manage systemd services for Master and Worker processes.

### 2.3 Automation Scripts
The project lifecycle is managed by a suite of Bash scripts located in the `scripts/` directory, abstracting the complexity of the underlying tools:

*   **`deploy.sh`**: The master deployment script. It orchestrates the entire provisioning process by sequentially triggering Terraform, generating the inventory, preparing data files, and running Ansible playbooks.
*   **`generate_inventory.sh`**: A bridge between Terraform and Ansible. It parses the JSON output from Terraform (containing dynamic IP addresses) and generates a compliant `hosts.ini` inventory file for Ansible.
*   **`upsize.sh`**: A data preparation utility that expands a small text sample into a larger dataset (`filesample.txt`) to provide a meaningful workload for the benchmark.
*   **`upload_spark_artifact.sh`**: Handles the efficient distribution of Spark binaries to GCS, implementing the "upload once, download many" optimization.
*   **`update_filesample.sh`**: A utility script that forces edge and worker nodes to re-download the latest `filesample.txt` from the GCS bucket. This is useful when the input data file has been updated in the bucket and needs to be refreshed on all nodes without redeploying the entire cluster.
*   **`submit_job.sh`**: Automates the job submission process by establishing an SSH connection to the Edge node and invoking `spark-submit` with the correct cluster parameters.
*   **`benchmark.sh`**: A test runner that executes `submit_job.sh` multiple times with varying executor counts (1, 2, 4, 8) to gather performance metrics.

## 3. Methodology

The deployment and testing process follows a strict four-stage pipeline:

### 3.1 Infrastructure Provisioning
Terraform creates the GCP resources. It outputs connection details (IP addresses) to a JSON file, which serves as a dynamic inventory for the subsequent configuration phase.

### 3.2 Configuration Management
Ansible playbooks read the Terraform outputs and configure the nodes. This includes:
*   Installing Java and system utilities.
*   **Deploying Spark binaries**:
    *   *Optimization*: The Spark distribution (`.tgz`) is uploaded to a GCS bucket once. All nodes then download the artifact from this internal mirror. We observed that this method is significantly faster and more reliable than having each node individually download from public Apache archives.
*   **Deploying input data files**:
    *   The benchmark input file (`filesample.txt`) is downloaded from GCS to `/tmp/filesample.txt` on edge and worker nodes during initial deployment. The `update_filesample.sh` script can be used to force a refresh of this file from GCS after deployment, enabling data updates without full cluster redeployment.
*   Configuring the Master node and starting the `spark-master` service.
*   Configuring Worker nodes to register with the Master.

### 3.3 Benchmarking Strategy
To validate the cluster's performance, a **WordCount** application (MapReduce pattern) was executed.
*   **Constraint**: The `e2-micro` instances have limited RAM (1GB). To prevent OOM (Out Of Memory) errors on the worker nodes, the Spark job was explicitly configured with `--executor-memory 512m`. This leaves approximately 500MB for the OS and overhead, which is the maximum safe allocation for this instance type.
*   **Workload**: Counting word frequencies in a sample text file (`filesample.txt`).
*   **Variables**: The number of Spark Executors was varied (1, 2, 4, and 8) to measure scalability.
*   **Metrics**: Execution time (in milliseconds) and relative speedup were recorded.

## 4. Testing Results

The benchmark was executed successfully. Below are the recorded performance metrics.

### 4.1 Performance Data

| Executors | Time (ms) | Speedup (Approx) |
|-----------|-----------|------------------|
| 1         | 9153      | 1.00x            |
| 2         | 9009      | 1.01x            |
| 4         | 8722      | 1.04x            |
| 8         | 8747      | 1.04x            |

### 4.2 Analysis
The results show a **flat performance curve**.
*   **Baseline**: The job completed in ~9.15 seconds with a single executor.
*   **Scaling**: Increasing resources to 8 executors only reduced the time to ~8.75 seconds, yielding a negligible speedup of 1.04x.

**Interpretation**: The lack of significant speedup indicates that the dataset size (`filesample.txt`) was too small. The overhead of task scheduling, network communication, and shuffle operations in a distributed environment outweighed the benefits of parallel processing. For a dataset of this size, the job is bounded by startup/teardown latency rather than compute capacity.

## 5. Limitations

While the system successfully demonstrates automated Spark cluster deployment and execution, several limitations should be acknowledged:

### 5.1 Filesample Data Management
*   **Lack of Flexibility**: The filesample input file (`filesample.txt`) is hardcoded in multiple places throughout the system. The filename, location (`/tmp/filesample.txt`), and source bucket are not configurable, making it difficult to use different input files or change data sources without modifying scripts and playbooks.
*   **Manual Update Process**: Updating the filesample file requires manual intervention. Users must:
    1.  Manually upload the new file to the GCS bucket
    2.  Explicitly run the `update_filesample.sh` script to propagate changes to all nodes
    3.  Ensure the file is properly formatted and accessible before job submission
*   **No Automatic Synchronization**: There is no mechanism to automatically detect when the source file in GCS has changed. The system does not poll for updates or trigger refreshes based on file modifications, requiring users to remember to run the update script after making changes.
*   **Single File Constraint**: The current implementation only supports a single input file. Processing multiple files or dynamic file selection requires code modifications.

### 5.2 Instance Resource Constraints
*   **Limited Memory**: The use of `e2-micro` instances (1GB RAM) severely constrains the executor memory allocation, limiting the size of datasets that can be processed effectively.
*   **No Dynamic Scaling**: The cluster size is fixed at deployment time. Adding or removing worker nodes requires a full redeployment.

### 5.3 Benchmarking Constraints
*   **Small Dataset Impact**: As demonstrated in the results, the current dataset size is insufficient to demonstrate meaningful distributed processing benefits, making it difficult to validate true scalability.

## 6. Conclusions

The project successfully established a functional, automated Spark cluster on GCP.

1.  **Automation Success**: The Terraform and Ansible pipeline reliably creates and configures the complex multi-node environment without manual intervention.
2.  **Functional Integrity**: The cluster successfully accepted, scheduled, and executed Spark jobs, proving the architecture is sound.
3.  **Scalability Insight**: While the infrastructure supports scaling, effective benchmarking requires a workload proportional to the compute power. Future tests should utilize datasets in the Gigabyte or Terabyte range to properly demonstrate the speedup capabilities of the distributed architecture.

## 7. Future Work

Based on the limitations identified and lessons learned during implementation, the following enhancements are recommended for future iterations:

*   **Configurable Input Files**: Implement a configuration system (e.g., environment variables or a config file) to allow users to specify input file names, paths, and GCS bucket locations without modifying source code. This would make the system flexible enough to handle different datasets and use cases.
*   **Automatic File Synchronization**: Develop a mechanism to automatically detect changes in GCS source files and trigger updates across cluster nodes. This could be implemented using:
    *   GCS object change notifications with Cloud Functions
    *   Periodic polling with a lightweight daemon on each node
    *   Event-driven updates via Pub/Sub
*   **Multi-File Support**: Extend the system to support processing multiple input files, either as a batch or as a single distributed dataset. This would enable more complex workloads and better utilize Spark's distributed processing capabilities.
*   **Direct GCS Integration**: Instead of downloading files to local storage, leverage Spark's native GCS connector to read directly from cloud storage. This would eliminate the need for local file management and reduce storage requirements on worker nodes.