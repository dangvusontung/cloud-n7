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
    The cluster consists of `e2-micro` instances organized into three roles:
    1.  **Master Node (1)**: Manages the Spark cluster resources and job scheduling.
    2.  **Worker Nodes (3)**: Execute the actual data processing tasks.
    3.  **Edge Node (1)**: Acts as a gateway for users to submit jobs and retrieve results, isolating the cluster from direct external access.

*   **Storage**:
    *   **GCS Buckets**: Used for storing build artifacts (Spark binaries) and log data, ensuring persistence beyond the cluster lifecycle.

### 2.2 Software Stack
*   **Operating System**: Linux (Debian/Ubuntu based).
*   **Core Engine**: Apache Spark 2.4.3 (bundled with Hadoop 2.7).
*   **Runtime**: OpenJDK 8.
*   **Orchestration**: Ansible is used to idempotently install dependencies, configure Spark `spark-env.sh`, and manage systemd services for Master and Worker processes.

## 3. Methodology

The deployment and testing process follows a strict four-stage pipeline:

### 3.1 Infrastructure Provisioning
Terraform creates the GCP resources. It outputs connection details (IP addresses) to a JSON file, which serves as a dynamic inventory for the subsequent configuration phase.

### 3.2 Configuration Management
Ansible playbooks read the Terraform outputs and configure the nodes. This includes:
*   Installing Java and system utilities.
*   Deploying Spark binaries.
*   Configuring the Master node and starting the `spark-master` service.
*   Configuring Worker nodes to register with the Master.

### 3.3 Benchmarking Strategy
To validate the cluster's performance, a **WordCount** application (MapReduce pattern) was executed.
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

## 5. Conclusions

The project successfully established a functional, automated Spark cluster on GCP.

1.  **Automation Success**: The Terraform and Ansible pipeline reliably creates and configures the complex multi-node environment without manual intervention.
2.  **Functional Integrity**: The cluster successfully accepted, scheduled, and executed Spark jobs, proving the architecture is sound.
3.  **Scalability Insight**: While the infrastructure supports scaling, effective benchmarking requires a workload proportional to the compute power. Future tests should utilize datasets in the Gigabyte or Terabyte range to properly demonstrate the speedup capabilities of the distributed architecture.

The system is ready for production-grade workloads, provided the data volume justifies the distributed processing overhead.

