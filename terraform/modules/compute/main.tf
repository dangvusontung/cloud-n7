resource "google_compute_instance" "spark_master" {
  name         = "${var.cluster_name}-master"
  machine_type = var.master_machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["spark-cluster", "spark-master"]

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y python3-pip
    EOT
}

resource "google_compute_instance" "spark_workers" {
  count        = var.worker_count
  name         = "${var.cluster_name}-worker-${count.index + 1}"
  machine_type = var.worker_machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["spark-cluster", "spark-worker"]

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y python3-pip
    EOT
}

resource "google_compute_instance" "spark_edge" {
  name         = "${var.cluster_name}-edge"
  machine_type = var.edge_machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["spark-cluster", "spark-edge"]

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = var.disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y python3-pip
    EOT
}
