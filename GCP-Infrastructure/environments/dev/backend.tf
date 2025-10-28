terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "gcp-sso/dev"
  }
}