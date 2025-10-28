variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "machine_type" {
  description = "Machine type for compute instance"
  type        = string
  default     = "e2-micro"
}

variable "boot_image" {
  description = "Boot disk image"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
}

variable "startup_script" {
  description = "Startup script content"
  type        = string
  default     = ""
}

variable "preemptible" {
  description = "Use preemptible instance for cost savings"
  type        = bool
  default     = true
}