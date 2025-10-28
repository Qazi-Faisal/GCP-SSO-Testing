output "instance_name" {
  description = "Instance name"
  value       = google_compute_instance.app_server.name
}

output "external_ip" {
  description = "External IP address"
  value       = google_compute_instance.app_server.network_interface[0].access_config[0].nat_ip
}

output "internal_ip" {
  description = "Internal IP address"
  value       = google_compute_instance.app_server.network_interface[0].network_ip
}