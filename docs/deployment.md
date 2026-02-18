# Deployment & Operations Guide

## Prerequisites
- AWS Account with Admin access
- GCP Project with Billing enabled
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
   terraform plan
   ```
4. Apply infrastructure:
   ```bash
   terraform apply
   ```

### GCP
1. Navigate to `terraform/gcp`.
2. Initialize:
   ```bash
   terraform init
   ```
3. Plan:
   ```bash
   terraform plan
   ```
4. Apply:
   ```bash
   terraform apply
   ```

## CI/CD Pipeline
GitHub Actions are configured in `.github/workflows`.

### Secrets Required
- `AWS_ACCESS_KEY_ID`: AWS Access Key.
- `AWS_SECRET_ACCESS_KEY`: AWS Secret Key.
- `GCP_PROJECT_ID`: GCP Project ID.
- `GCP_CREDENTIALS`: GCP Service Account JSON Key (Base64 encoded or direct JSON).
- `NEXT_PUBLIC_API_URL`: The URL of the deployed backend (Required for Frontend build on AWS).

## Monitoring & Failure Handling
- **AWS**: Monitor CloudWatch path for ECS metrics and ALB 5XX errors.
- **GCP**: Use Cloud Monitoring and Error Reporting.
- **Failure**: Both platforms auto-restart failed containers.

## Rollback Strategy
- **Infrastructure**: `terraform revert` or apply previous state.
- **Application**: Revert git commit to trigger previous image build/deploy.
