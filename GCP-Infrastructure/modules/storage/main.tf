resource "google_storage_bucket" "app_bucket" {
  name     = "${var.project_id}-${var.project_name}-bucket"
  location = var.region
  uniform_bucket_level_access = true
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
  versioning {
    enabled = false
  }
}
