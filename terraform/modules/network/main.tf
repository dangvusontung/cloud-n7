resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["spark-cluster"]
}

resource "google_compute_firewall" "allow_spark_ui" {
  name    = "${var.network_name}-allow-spark-ui"
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["8080", "4040"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["spark-cluster"]
}

resource "google_compute_firewall" "allow_spark_worker" {
  name    = "${var.network_name}-allow-spark-worker"
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["7077", "8081", "8082"]
  }

  source_tags = ["spark-cluster"]
  target_tags = ["spark-cluster"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]  # All TCP ports for internal communication (including ephemeral ports for Spark driver-executor)
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_tags = ["spark-cluster"]
  target_tags = ["spark-cluster"]
}

