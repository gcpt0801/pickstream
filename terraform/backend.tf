terraform {
  backend "gcs" {
    bucket = "gcp-tftbk"
    prefix = "pickstream/terraform/state"
  }
}
