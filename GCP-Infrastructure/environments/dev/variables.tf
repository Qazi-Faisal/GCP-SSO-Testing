variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = null
  validation {
    condition     = var.project_id != null
    error_message = "Set TF_VAR_project_id environment variable or pass -var project_id=VALUE"
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "gcp-sso-dev"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "machine_type" {
  description = "Machine type for compute instance"
  type        = string
  default     = "e2-micro"
}

variable "preemptible" {
  description = "Use preemptible instance for cost savings"
  type        = bool
  default     = true
}