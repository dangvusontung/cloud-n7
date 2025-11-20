variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Spark cluster"
  type        = string
  default     = "spark"
}

variable "zone" {
  description = "GCP Zone"
  type = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type = string
}

variable "master_machine_type" {
  description = "Machine type for Spark master node"
  type        = string
  default     = "e2-micro"
}

variable "worker_machine_type" {
  description = "Machine type for Spark worker nodes"
  type        = string
  default     = "e2-micro"
}

variable "edge_machine_type" {
  description = "Machine type for Edge node"
  type        = string
  default     = "e2-micro"
}

variable "worker_count" {
  description = "Number of Spark worker nodes"
  type        = number
  default     = 3
}

variable "os_image" {
  description = "OS image for intances"
  type = string
  default = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "disk_size" {
  description = "Disk size in image"
  type = number
  default = 100
}

variable "ssh_user" {
  description = "SSH username"
  type = string
  default = "sparkuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type = string
  default = "~/.ssh/spark-cluster-key.pub"
}

variable "service_account_email" {
  description = "Service Account Email"
  type = string
  default = ""
}
