variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "network_name" {
  description = "Name of VPC Network"
  type        = string
  default     = "spark-vpc-network"
}

variable "subnet_name" {
  description = "Name of subnet"
  type        = string
  default     = "spark-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "region" {
  description = "GCP Region"
  type        = string
}
