# GCS Bucket for Spark Data (input/output)
resource "google_storage_bucket" "spark_data" {
  name          = "${var.project_id}-${var.cluster_name}-data"
  location      = var.region
  project       = var.project_id
  force_destroy = var.force_destroy_buckets

  uniform_bucket_level_access = true

  versioning {
    enabled = var.enable_versioning
  }

  lifecycle_rule {
    condition {
      age = var.data_retention_days
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    component   = "spark-data"
    managed_by  = "terraform"
  }
}

# GCS Bucket for Spark Event Logs
resource "google_storage_bucket" "spark_event_logs" {
  name          = "${var.project_id}-${var.cluster_name}-event-logs"
  location      = var.region
  project       = var.project_id
  force_destroy = var.force_destroy_buckets

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition {
      age = var.event_log_retention_days
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    component   = "spark-logs"
    managed_by  = "terraform"
  }
}

# GCS Bucket for Application Artifacts (JARs, Python files, etc.)
resource "google_storage_bucket" "spark_artifacts" {
  name          = "${var.project_id}-${var.cluster_name}-artifacts"
  location      = var.region
  project       = var.project_id
  force_destroy = var.force_destroy_buckets

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = {
    environment = var.environment
    component   = "spark-artifacts"
    managed_by  = "terraform"
  }
}

# IAM binding: Grant service account access to buckets
resource "google_storage_bucket_iam_member" "spark_data_access" {
  bucket = google_storage_bucket.spark_data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.service_account_email}"
}

resource "google_storage_bucket_iam_member" "spark_event_logs_access" {
  bucket = google_storage_bucket.spark_event_logs.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.service_account_email}"
}

resource "google_storage_bucket_iam_member" "spark_artifacts_access" {
  bucket = google_storage_bucket.spark_artifacts.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.service_account_email}"
}

