output "data_bucket_name" {
  description = "Name of the Spark data bucket"
  value       = google_storage_bucket.spark_data.name
}

output "data_bucket_url" {
  description = "GCS URL for the Spark data bucket"
  value       = "gs://${google_storage_bucket.spark_data.name}"
}

output "event_logs_bucket_name" {
  description = "Name of the Spark event logs bucket"
  value       = google_storage_bucket.spark_event_logs.name
}

output "event_logs_bucket_url" {
  description = "GCS URL for the Spark event logs bucket"
  value       = "gs://${google_storage_bucket.spark_event_logs.name}"
}

output "artifacts_bucket_name" {
  description = "Name of the Spark artifacts bucket"
  value       = google_storage_bucket.spark_artifacts.name
}

output "artifacts_bucket_url" {
  description = "GCS URL for the Spark artifacts bucket"
  value       = "gs://${google_storage_bucket.spark_artifacts.name}"
}

