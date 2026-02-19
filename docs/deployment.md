# Deployment & Operations Guide

## Prerequisites
- AWS Account with Admin access
- Azure Subscription with Contributor access
- Terraform installed
- Docker installed
- GitHub Account (for CI/CD)

## Infrastructure Deployment (IaC)

### AWS
1. Navigate to `terraform/aws`.
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Plan deployment and check for errors:
   ```bash
   terraform plan -var-file=envs/prod.tfvars
   ```
4. Apply infrastructure:
   ```bash
   terraform apply -var-file=envs/prod.tfvars
   ```

### Azure
1. Navigate to `terraform/azure`.
2. Login to Azure CLI:
   ```bash
   az login
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Plan deployment:
   ```bash
   terraform plan -var-file=envs/prod.tfvars
   ```
5. Apply infrastructure:
   ```bash
   terraform apply -var-file=envs/prod.tfvars
   ```

## CI/CD Pipeline
GitHub Actions are configured in `.github/workflows`.

### Secrets Required
- `AWS_ACCESS_KEY_ID`: AWS Access Key.
- `AWS_SECRET_ACCESS_KEY`: AWS Secret Key.
- `AZURE_CREDENTIALS`: Azure Service Principal JSON (`az ad sp create-for-rbac` output).
- `NEXT_PUBLIC_API_URL`: The URL of the deployed backend (Required for Frontend build on AWS).

## Monitoring & Failure Handling
- **AWS**: Monitor CloudWatch for ECS metrics and ALB 5XX errors.
- **Azure**: Use Log Analytics workspace and Container App metrics/logs.
- **Failure**: Both platforms auto-restart failed containers/replicas.

## Rollback Strategy
- **Infrastructure**: `terraform apply` with previous state or revert the Terraform code commit.
- **Application**: Revert git commit to trigger previous image build/deploy.
- **Azure**: Switch to previous Container Apps revision for instant rollback.
