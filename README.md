# GCP SSO Infrastructure - Enterprise Structure

Cost-effective GCP infrastructure with modular Terraform design and SSO authentication testing.

## Directory Structure : 

```
gcp-sso/
├── GCP-Infrastructure/        # Terraform infrastructure code
│   ├── modules/               # Reusable Terraform modules
│   │   ├── compute/           # Compute Engine instances
│   │   ├── network/           # VPC, subnets, firewall rules
│   │   ├── storage/           # Cloud Storage buckets
│   │   └── iam/               # Service accounts and IAM roles
│   ├── environments/          # Environment-specific configurations
│   │   └── dev/               # Development environment
│   │       ├── backend.tf     # Remote state configuration
│   │       ├── main.tf        # Module imports and configuration
│   │       ├── variables.tf   # Environment variables
│   │       └── outputs.tf     # Environment outputs
│   └── versions.tf            # Provider versions
└── Application/               # Application code
    └── app/                   # Application directory
        └── sso-login/         # SSO test application
            ├── app.py         # Flask SSO application
            ├── requirements.txt # Python dependencies
            └── startup.sh     # Deployment script
```

## Cost Optimization Features

- **Preemptible instances** (80% cost reduction)
- **e2-micro machine type** (free tier eligible)
- **10GB standard persistent disk**
- **Storage lifecycle rules** (auto-delete after 30 days)
- **Minimal IAM permissions**

## Quick Start

### 1. Prerequisites
```bash
# Enable required APIs
gcloud services enable compute.googleapis.com storage.googleapis.com iam.googleapis.com

# Create state bucket (replace with your bucket name)
gsutil mb gs://your-terraform-state-bucket
```

### 2. Deploy Infrastructure

**Option 1: Using environment variables (Recommended)**
```bash
cd GCP-Infrastructure/environments/dev
export PROJECT_ID=your-gcp-project-id
./deploy.sh
```

**Option 2: Using command line variables**
```bash
cd GCP-Infrastructure/environments/dev
terraform init
terraform plan -var="project_id=your-gcp-project-id"
terraform apply -var="project_id=your-gcp-project-id"
```

**Option 3: Interactive input**
```bash
cd GCP-Infrastructure/environments/dev
terraform init
terraform plan  # Will prompt for project_id
terraform apply
```

### 4. Configure OAuth 2.0
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to APIs & Services > Credentials
3. Create OAuth 2.0 Client ID:
   - Application type: Web application
   - Authorized redirect URIs: `http://SERVER_IP/callback`

### 5. Configure SSO App
```bash
# Get server IP
terraform output app_server_ip

# SSH to server
gcloud compute ssh gcp-sso-dev-server --zone=us-central1-a

# Set OAuth credentials
sudo systemctl edit sso-app
# Add:
# [Service]
# Environment="GOOGLE_CLIENT_ID=your-client-id"
# Environment="GOOGLE_CLIENT_SECRET=your-client-secret"
# Environment="REDIRECT_URI=http://YOUR_SERVER_IP/callback"

sudo systemctl restart sso-app
```

## Module Usage

### Network Module
- Creates VPC with custom subnet
- Configures firewall rules for HTTP and SSH
- Outputs network identifiers for other modules

### Compute Module
- Deploys cost-optimized VM instances
- Supports preemptible instances
- Configurable machine types and disk sizes

### IAM Module
- Creates service accounts with minimal permissions
- Configurable IAM role assignments
- Follows principle of least privilege

### Storage Module
- Creates Cloud Storage buckets
- Implements lifecycle management
- Cost-optimized storage classes

## Testing SSO

1. Get server IP: `terraform output app_server_ip`
2. Update OAuth redirect URI with actual IP
3. Visit `http://SERVER_IP` to test SSO login
4. Check `/health` endpoint for app status

## Environment Management

To create additional environments (staging, prod):
```bash
cp -r environments/dev environments/staging
# Update variables and backend configuration
```

## Cleanup
```bash
cd GCP-Infrastructure/environments/dev
terraform destroy
```

## Cost Estimation

**Monthly costs (us-central1):**
- e2-micro preemptible: ~$3.50
- 10GB standard disk: ~$0.40
- Network egress: ~$0.12/GB
- **Total: ~$4-6/month**