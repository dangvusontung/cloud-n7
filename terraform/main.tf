terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "> 5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

# Network Module
module "network" {
  source = "./modules/network"

  project_id   = var.project_id
  region       = var.region
  network_name = var.network_name
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_id            = var.project_id
  zone                  = var.zone
  subnet_id             = module.network.subnet_id
  cluster_name          = var.cluster_name
  master_machine_type   = var.master_machine_type
  worker_machine_type   = var.worker_machine_type
  edge_machine_type     = var.edge_machine_type
  worker_count          = var.worker_count
  ssh_user              = var.ssh_user
  ssh_public_key_path   = var.ssh_public_key_path
  service_account_email = var.service_account_email
}

# Storage Module (GCS Buckets)
module "storage" {
  count  = var.enable_storage_buckets ? 1 : 0
  source = "./modules/storage"

  project_id               = var.project_id
  region                   = var.region
  cluster_name             = var.cluster_name
  service_account_email    = var.service_account_email
  environment              = var.environment
  force_destroy_buckets    = var.force_destroy_buckets
  enable_versioning        = var.enable_bucket_versioning
  data_retention_days      = var.data_retention_days
  event_log_retention_days = var.event_log_retention_days
}

# Note: Firewall rules are now managed in the network module
# This ensures consistency and follows the guide's recommended structure