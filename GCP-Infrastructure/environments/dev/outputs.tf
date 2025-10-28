output "app_server_ip" {
  description = "External IP of the app server"
  value       = module.compute.external_ip
}

output "app_server_internal_ip" {
  description = "Internal IP of the app server"
  value       = module.compute.internal_ip
}

output "service_account_email" {
  description = "Service account email"
  value       = module.iam.service_account_email
}

output "bucket_name" {
  description = "Storage bucket name"
  value       = module.storage.bucket_name
}

output "instance_name" {
  description = "Instance name"
  value       = module.compute.instance_name
}