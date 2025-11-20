locals {
  spark_archive_upload_enabled = var.enable_storage_buckets && var.enable_auto_artifact_upload && var.spark_archive_local_path != ""
  spark_archive_object_name    = var.spark_archive_object_name != "" ? var.spark_archive_object_name : (var.spark_archive_local_path != "" ? basename(var.spark_archive_local_path) : "")
  sample_input_path            = var.sample_input_local_path != "" ? var.sample_input_local_path : "${path.module}/../ansible/examples/filesample.txt"
  sample_input_object_name     = var.sample_input_object_name != "" ? var.sample_input_object_name : basename(local.sample_input_path)
  sample_input_upload_enabled  = var.enable_storage_buckets && var.enable_auto_artifact_upload && local.sample_input_path != ""
}

resource "google_storage_bucket_object" "spark_archive" {
  count = local.spark_archive_upload_enabled ? 1 : 0

  bucket = module.storage[0].artifacts_bucket_name
  name   = local.spark_archive_object_name
  source = var.spark_archive_local_path
}

resource "google_storage_bucket_object" "wordcount_sample" {
  count = local.sample_input_upload_enabled ? 1 : 0

  bucket = module.storage[0].artifacts_bucket_name
  name   = local.sample_input_object_name
  source = local.sample_input_path
}

