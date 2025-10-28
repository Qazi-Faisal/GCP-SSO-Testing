output "vpc_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.subnet.name
}

output "vpc_id" {
  description = "VPC network ID"
  value       = google_compute_network.vpc.id
}