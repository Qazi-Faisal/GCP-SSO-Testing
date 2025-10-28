output "bucket_name" {
  description = "Storage bucket name"
  value       = google_storage_bucket.app_bucket.name
}

output "bucket_url" {
  description = "Storage bucket URL"
  value       = google_storage_bucket.app_bucket.url
}