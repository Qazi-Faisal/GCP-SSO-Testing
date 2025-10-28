#!/bin/bash

# Set required environment variables
export TF_VAR_project_id="${PROJECT_ID:-$(gcloud config get-value project)}"

# Validate project ID : 
if [ -z "$TF_VAR_project_id" ]; then
    echo "Error: PROJECT_ID not set. Use: export PROJECT_ID=your-project-id"
    exit 1
fi

echo "Deploying to project: $TF_VAR_project_id"

# Deploy infrastructure
terraform init
terraform plan
terraform apply -auto-approve