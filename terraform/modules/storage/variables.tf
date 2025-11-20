variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name prefix for bucket naming"
  type        = string
  default     = "spark"
}

variable "region" {
  description = "GCP region for bucket location"
  type        = string
}

variable "service_account_email" {
  description = "Service account email for IAM bindings"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "force_destroy_buckets" {
  description = "Force destroy buckets even if they contain objects"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable versioning on data bucket"
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


