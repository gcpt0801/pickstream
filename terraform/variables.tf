variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "The name of the compute instance"
  type        = string
  default     = "pickstream-instance"
}

variable "machine_type" {
  description = "Machine type for the instance"
  type        = string
  default     = "e2-medium"
}

variable "image_family" {
  description = "Custom image family created by Packer"
  type        = string
  default     = "pickstream"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "webapp-network"
}

variable "allowed_ports" {
  description = "List of ports to allow in firewall"
  type        = list(string)
  default     = ["8080", "80", "443"]
}

variable "tags" {
  description = "Network tags for the instance"
  type        = list(string)
  default     = ["webapp", "http-server"]
}
