variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "service_account_roles" {
  description = "List of IAM roles for service account"
  type        = list(string)
  default     = ["roles/compute.serviceAgent"]
}