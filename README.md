# DevOps Assignment — Cloud Infrastructure

[![Deploy to AWS](https://github.com/PrithviRajReddy24/DevOps-Assignment/actions/workflows/aws.yml/badge.svg)](https://github.com/PrithviRajReddy24/DevOps-Assignment/actions/workflows/aws.yml)
[![Deploy to Azure](https://github.com/PrithviRajReddy24/DevOps-Assignment/actions/workflows/azure.yml/badge.svg)](https://github.com/PrithviRajReddy24/DevOps-Assignment/actions/workflows/azure.yml)

## Overview
Production-grade infrastructure for deploying a **Next.js Frontend** + **FastAPI Backend** to **AWS (ECS Fargate)** and **Azure (Container Apps)** with full IaC, CI/CD, environment separation, and operational documentation.

## Architecture Summary

| Component | AWS | Azure |
|-----------|-----|-------|
| **Compute** | ECS Fargate | Container Apps |
| **Networking** | VPC + ALB + NAT | Container Apps Environment (managed) |
| **Region** | `us-east-1` | `eastus` |
| **Scaling** | ECS Auto Scaling (CPU-based) | Auto (HTTP-based, scale-to-zero) |
| **State** | S3 + DynamoDB locking | Azure Storage Account (blob + lease locking) |
| **CI/CD** | GitHub Actions → ECR → ECS | GitHub Actions → ACR → Container Apps |

## 📁 Repository Structure
```
├── backend/                  # FastAPI backend
│   ├── app/main.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/                 # Next.js frontend
│   ├── pages/index.js
│   ├── package.json
│   └── Dockerfile
├── terraform/
│   ├── aws/                  # AWS IaC (VPC, ECS, ALB, Auto Scaling)
│   │   ├── main.tf
│   │   ├── vpc.tf
│   │   ├── security.tf
│   │   ├── compute.tf
│   │   ├── autoscaling.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── envs/             # Environment-specific configs
│   │       ├── dev.tfvars
│   │       ├── staging.tfvars
│   │       └── prod.tfvars
│   └── azure/                # Azure IaC (Container Apps)
│       ├── main.tf
│       ├── compute.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── envs/
│           ├── dev.tfvars
│           ├── staging.tfvars
│           └── prod.tfvars
├── .github/workflows/        # CI/CD Pipelines
│   ├── aws.yml
│   └── azure.yml
├── docs/                     # Documentation
│   ├── architecture.md       # Full architecture doc (all 10 requirements)
│   ├── deployment.md         # Deployment guide
│   └── decisions.md          # "What We Did NOT Do"
├── docker-compose.yml        # Local development
└── setup.ps1                 # Prerequisites checker
```

## 🚀 Run Locally
```bash
# Using Docker Compose:
docker-compose up --build

# Frontend: http://localhost:3000
# Backend:  http://localhost:8000/api/health
```

## 🛠️ Deploy Infrastructure
```bash
# AWS (example: dev environment)
cd terraform/aws
terraform init
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars

# Azure (example: prod environment)
cd terraform/azure
terraform init
terraform plan -var-file=envs/prod.tfvars
terraform apply -var-file=envs/prod.tfvars
```

## 📌 Deliverables
- **Architecture Documentation**: [docs/architecture.md](docs/architecture.md)
- **Deployment Guide**: [docs/deployment.md](docs/deployment.md)
- **Design Decisions**: [docs/decisions.md](docs/decisions.md)
- **Demo Video**: *(Link to be added)*
- **Live URLs**:
  - **AWS**: http://da-prod-alb-686014369.us-east-1.elb.amazonaws.com
  - **Azure Frontend**: https://devops-assignment-prod-frontend.victoriouspebble-7210f9a5.eastus.azurecontainerapps.io
  - **Azure Backend**: https://devops-assignment-prod-backend.victoriouspebble-7210f9a5.eastus.azurecontainerapps.io

## 📖 Documentation Highlights
The [architecture document](docs/architecture.md) covers:
1. Cloud & Region Selection with justifications
2. Compute & Runtime Decisions (ECS Fargate vs Container Apps)
3. Networking & Traffic Flow with diagrams
4. Environment Separation (dev/staging/prod)
5. Scalability & Availability strategy
6. Deployment & Rollback strategy
7. IaC & State Management
8. Security & Identity (least privilege)
9. Failure & Operational Thinking
10. Future Growth Scenarios
11. What We Intentionally Did NOT Do (and why)
