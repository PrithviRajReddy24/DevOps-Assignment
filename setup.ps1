# DevOps Assignment Setup Script

Write-Host "Checking prerequisites..." -ForegroundColor Cyan

# Check Terraform
if (Get-Command "terraform" -ErrorAction SilentlyContinue) {
    Write-Host "✅ Terraform is installed." -ForegroundColor Green
} else {
    Write-Host "❌ Terraform is NOT installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Terraform: https://developer.hashicorp.com/terraform/install"
}

# Check AWS CLI
if (Get-Command "aws" -ErrorAction SilentlyContinue) {
    Write-Host "✅ AWS CLI is installed." -ForegroundColor Green
} else {
    Write-Host "⚠️ AWS CLI is NOT installed or not in PATH." -ForegroundColor Yellow
    Write-Host "You will need it to configure credentials: https://aws.amazon.com/cli/"
}

# Check Google Cloud SDK
if (Get-Command "gcloud" -ErrorAction SilentlyContinue) {
    Write-Host "✅ Google Cloud SDK is installed." -ForegroundColor Green
} else {
    Write-Host "⚠️ Google Cloud SDK is NOT installed or not in PATH." -ForegroundColor Yellow
    Write-Host "You will need it to configure credentials: https://cloud.google.com/sdk/docs/install"
}

# Check Docker
if (Get-Command "docker" -ErrorAction SilentlyContinue) {
    Write-Host "✅ Docker is installed." -ForegroundColor Green
} else {
    Write-Host "❌ Docker is NOT installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Docker Desktop: https://www.docker.com/products/docker-desktop/"
}

Write-Host "`n--------------------------------------------------"
Write-Host "Instructions to Run the Project" -ForegroundColor Cyan
Write-Host "--------------------------------------------------"
Write-Host "1. Configure AWS Credentials:"
Write-Host "   Run: aws configure"
Write-Host "`n2. Configure GCP Credentials:"
Write-Host "   Run: gcloud auth application-default login"
Write-Host "`n3. Set up Terraform State Storage (AWS):"
Write-Host "   You need to manually create an S3 bucket named 'devops-assignment-tf-state-prithvirajreddy' and a DynamoDB table named 'devops-assignment-tf-lock' (Partition key: LockID) in us-east-1."
Write-Host "`n4. Set up Terraform State Storage (GCP):"
Write-Host "   You need to manually create a GCS bucket named 'devops-assignment-tf-state-prithvirajreddy'."
Write-Host "`n5. Deploy AWS Infrastructure:"
Write-Host "   cd terraform/aws"
Write-Host "   terraform init"
Write-Host "   terraform apply"
Write-Host "`n6. Deploy GCP Infrastructure:"
Write-Host "   cd terraform/gcp"
Write-Host "   terraform init"
Write-Host "   terraform apply"
