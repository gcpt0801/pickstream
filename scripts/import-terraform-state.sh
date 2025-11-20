# Script to import existing GCP resources into Terraform state

# Import the network
terraform import google_compute_network.webapp_network projects/gcp-terraform-demo-474514/global/networks/webapp-network

# Import the static IP
terraform import google_compute_address.webapp_static_ip projects/gcp-terraform-demo-474514/regions/us-central1/addresses/pickstream-instance-static-ip

# Import the firewall rules
terraform import google_compute_firewall.allow_http projects/gcp-terraform-demo-474514/global/firewalls/webapp-network-allow-http
terraform import google_compute_firewall.allow_tomcat projects/gcp-terraform-demo-474514/global/firewalls/webapp-network-allow-tomcat
terraform import google_compute_firewall.allow_ssh projects/gcp-terraform-demo-474514/global/firewalls/webapp-network-allow-ssh

# Import the compute instance
terraform import google_compute_instance.webapp_instance projects/gcp-terraform-demo-474514/zones/us-central1-a/instances/pickstream-instance

# After importing, run:
# terraform plan
# terraform apply
