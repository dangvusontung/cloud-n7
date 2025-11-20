# Helpers
locals {
  storage_module = var.enable_storage_buckets ? module.storage[0] : null
}

# Output master information
output "master_external_ip" {
  description = "External IP address of Spark Master"
  value       = module.compute.master_external_ip
}

output "master_internal_ip" {
  description = "Internal IP address of Spark Master"
  value       = module.compute.master_internal_ip
}

# Output worker information
output "worker_external_ips" {
  description = "External IP addresses of Spark Workers"
  value       = module.compute.worker_external_ips
}

output "worker_internal_ips" {
  description = "Internal IP addresses of Spark Workers"
  value       = module.compute.worker_internal_ips
}

# Output edge information
output "edge_external_ip" {
  description = "External IP address of Spark Edge Node"
  value       = module.compute.edge_external_ip
}

output "edge_internal_ip" {
  description = "Internal IP address of Spark Edge Node"
  value       = module.compute.edge_internal_ip
}

# Output all IPs in a format suitable for Ansible inventory
output "ansible_inventory_data" {
  description = "All IPs formatted for Ansible inventory"
  value = {
    master = {
      external_ip = module.compute.master_external_ip
      internal_ip = module.compute.master_internal_ip
    }
    workers = [
      for i in range(var.worker_count) : {
        external_ip = module.compute.worker_external_ips[i]
        internal_ip = module.compute.worker_internal_ips[i]
      }
    ]
    edge = {
      external_ip = module.compute.edge_external_ip
      internal_ip = module.compute.edge_internal_ip
    }
  }
}

# Output GCS Bucket Information
output "data_bucket_name" {
  description = "Name of the Spark data bucket"
  value       = var.enable_storage_buckets ? local.storage_module.data_bucket_name : null
}

output "data_bucket_url" {
  description = "GCS URL for the Spark data bucket"
  value       = var.enable_storage_buckets ? local.storage_module.data_bucket_url : null
}

output "event_logs_bucket_name" {
  description = "Name of the Spark event logs bucket"
  value       = var.enable_storage_buckets ? local.storage_module.event_logs_bucket_name : null
}

output "event_logs_bucket_url" {
  description = "GCS URL for the Spark event logs bucket"
  value       = var.enable_storage_buckets ? local.storage_module.event_logs_bucket_url : null
}

output "artifacts_bucket_name" {
  description = "Name of the Spark artifacts bucket"
  value       = var.enable_storage_buckets ? local.storage_module.artifacts_bucket_name : null
}

output "artifacts_bucket_url" {
  description = "GCS URL for the Spark artifacts bucket"
  value       = var.enable_storage_buckets ? local.storage_module.artifacts_bucket_url : null
}

