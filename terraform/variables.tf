variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "credentials_file" {
  description = "Path to GCP credentials JSON file"
  type        = string
  default     = "../gcp-credentials.json"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "spark-vpc"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "spark-subnet"
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
  default     = "10.0.1.0/24"
}

variable "cluster_name" {
  description = "Cluster name prefix"
  type        = string
  default     = "spark"
}

variable "spark_version" {
  description = "Apache Spark version to install and upload"
  type        = string
  default     = "2.4.3"
}

variable "hadoop_version" {
  description = "Hadoop version that matches the Spark distribution"
  type        = string
  default     = "2.7"
}

variable "master_machine_type" {
  description = "Master node machine type"
  type        = string
  default     = "e2-micro"
}

variable "worker_machine_type" {
  description = "Worker node machine type"
  type        = string
  default     = "e2-micro"
}

variable "edge_machine_type" {
  description = "Edge node machine type"
  type        = string
  default     = "e2-micro"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "sparkuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/spark-cluster-key.pub"
}

variable "service_account_email" {
  description = "Service account email for VMs"
  type        = string
}

# Storage (GCS Buckets) Variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "enable_storage_buckets" {
  description = "Create supporting GCS buckets (requires storage.buckets.create permission)"
  type        = bool
  default     = true
}

variable "force_destroy_buckets" {
  description = "Force destroy buckets even if they contain objects (use with caution)"
  type        = bool
  default     = true
}

variable "enable_bucket_versioning" {
  description = "Enable versioning on data bucket"
  type        = bool
  default     = true
}

variable "enable_auto_artifact_upload" {
  description = "Automatically upload Spark artifacts to GCS using Terraform"
  type        = bool
  default     = true
}

variable "data_retention_days" {
  description = "Number of days to retain data before deletion (0 = no deletion)"
  type        = number
  default     = 90
}

variable "event_log_retention_days" {
  description = "Number of days to retain event logs before deletion (0 = no deletion)"
  type        = number
  default     = 30
}

variable "spark_archive_local_path" {
  description = "Absolute path to the local Spark archive (.tgz) that should be uploaded to the artifacts bucket (leave empty to skip)"
  type        = string
  default     = ""
}

variable "spark_archive_object_name" {
  description = "Object name to use when uploading the Spark archive (defaults to the local file basename when empty)"
  type        = string
  default     = "spark-2.4.3-bin-hadoop2.7.tgz"
}

variable "sample_input_local_path" {
  description = "Absolute path to the sample input file to upload to the artifacts bucket (leave empty to skip)"
  type        = string
  default     = ""
}

variable "sample_input_object_name" {
  description = "Object name to use when uploading the sample input file (defaults to the local file basename when empty)"
  type        = string
  default     = "filesample.txt"
}
