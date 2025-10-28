provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Network Module
module "network" {
  source = "../../modules/network"
  
  project_name = var.project_name
  region       = var.region
  subnet_cidr  = var.subnet_cidr
}

# IAM Module
module "iam" {
  source = "../../modules/iam"
  
  project_id   = var.project_id
  project_name = var.project_name
}

# Storage Module
module "storage" {
  source = "../../modules/storage"
  
  project_id   = var.project_id
  project_name = var.project_name
  region       = var.region
}

# Compute Module
module "compute" {
  source = "../../modules/compute"
  
  project_name           = var.project_name
  zone                   = var.zone
  machine_type           = var.machine_type
  vpc_name               = module.network.vpc_name
  subnet_name            = module.network.subnet_name
  service_account_email  = module.iam.service_account_email
  startup_script         = file("${path.module}/../../../Application/app/sso-login/startup.sh")
  preemptible           = var.preemptible
}