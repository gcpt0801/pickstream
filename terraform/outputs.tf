output "instance_name" {
  description = "Name of the compute instance"
  value       = google_compute_instance.webapp_instance.name
}

output "instance_external_ip" {
  description = "External IP address of the compute instance"
  value       = google_compute_address.webapp_static_ip.address
}

output "webapp_url" {
  description = "URL to access the web application"
  value       = "http://${google_compute_address.webapp_static_ip.address}:8080/pickstream"
}

output "instance_zone" {
  description = "Zone of the compute instance"
  value       = google_compute_instance.webapp_instance.zone
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.webapp_network.name
}
