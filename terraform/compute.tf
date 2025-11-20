# VPC Network
resource "google_compute_network" "webapp_network" {
  name                    = var.network_name
  auto_create_subnetworks = true
  description             = "Network for Random Names Web Application"
}

# Firewall rule to allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "${var.network_name}-allow-http"
  network = google_compute_network.webapp_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
  
  description = "Allow HTTP traffic from anywhere"
}

# Firewall rule to allow Tomcat traffic
resource "google_compute_firewall" "allow_tomcat" {
  name    = "${var.network_name}-allow-tomcat"
  network = google_compute_network.webapp_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webapp"]
  
  description = "Allow Tomcat traffic from anywhere"
}

# Firewall rule to allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.webapp_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  
  description = "Allow SSH from anywhere"
}

# Static IP address
resource "google_compute_address" "webapp_static_ip" {
  name   = "${var.instance_name}-static-ip"
  region = var.region
}

# Compute Instance
resource "google_compute_instance" "webapp_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.tags

  boot_disk {
    initialize_params {
      image = "projects/${var.project_id}/global/images/family/${var.image_family}"
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network = google_compute_network.webapp_network.name

    access_config {
      nat_ip = google_compute_address.webapp_static_ip.address
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    systemctl start tomcat9
    systemctl enable tomcat9
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true

  labels = {
    environment = "production"
    app         = "pickstream"
  }
}
