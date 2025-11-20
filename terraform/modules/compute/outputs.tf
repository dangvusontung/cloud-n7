output "master_name" {
  value = google_compute_instance.spark_master
}

output "master_internal_ip" {
  value = google_compute_instance.spark_master.network_interface[0].network_ip
}

output "master_external_ip" {
  value = google_compute_instance.spark_master.network_interface[0].access_config[0].nat_ip
}

output "worker_names" {
  value = google_compute_instance.spark_workers[*].name
}

output "worker_internal_ips" {
  value = google_compute_instance.spark_workers[*].network_interface[0].network_ip
}
output "worker_external_ips" {
  value = google_compute_instance.spark_workers[*].network_interface[0].access_config[0].nat_ip
}

output "edge_name" {
  value = google_compute_instance.spark_edge.name
  
}

output "edge_internal_ip" {
  value = google_compute_instance.spark_edge.network_interface[0].network_ip
}

output edge_external_ip {
  value = google_compute_instance.spark_edge.network_interface[0].access_config[0].nat_ip
}