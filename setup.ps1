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

# Check Azure CLI
if (Get-Command "az" -ErrorAction SilentlyContinue) {
    Write-Host "✅ Azure CLI is installed." -ForegroundColor Green
} else {
    Write-Host "⚠️ Azure CLI is NOT installed or not in PATH." -ForegroundColor Yellow
    Write-Host "You will need it to configure credentials: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
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
Write-Host "`n2. Configure Azure Credentials:"
Write-Host "   Run: az login"
Write-Host "`n3. Set up Terraform State Storage (AWS):"
Write-Host "   You need to manually create an S3 bucket named 'devops-assignment-tf-state-prithvirajreddy' and a DynamoDB table named 'devops-assignment-tf-lock' (Partition key: LockID) in us-east-1."
Write-Host "`n4. Set up Terraform State Storage (Azure):"
Write-Host "   You need to manually create an Azure Storage Account named 'devopsassigntfstate' with a blob container named 'tfstate'."
Write-Host "`n5. Deploy AWS Infrastructure:"
Write-Host "   cd terraform/aws"
Write-Host "   terraform init"
Write-Host "   terraform apply -var-file=envs/prod.tfvars"
Write-Host "`n6. Deploy Azure Infrastructure:"
Write-Host "   cd terraform/azure"
Write-Host "   terraform init"
Write-Host "   terraform apply -var-file=envs/prod.tfvars"
