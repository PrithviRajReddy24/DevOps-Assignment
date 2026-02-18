# DevOps Assignment — Cloud Infrastructure

[![Deploy to AWS](https://github.com/PrithviRajReddy24/DevOps-Assignment/actions/workflows/aws.yml/badge.svg)](https://github.com/PrithviRajReddy24/DevOps-Assignment/actions/workflows/aws.yml)
[![Deploy to GCP](https://github.com/PrithviRajReddy24/DevOps-Assignment/actions/workflows/gcp.yml/badge.svg)](https://github.com/PrithviRajReddy24/DevOps-Assignment/actions/workflows/gcp.yml)

## Overview
Production-grade infrastructure for deploying a **Next.js Frontend** + **FastAPI Backend** to **AWS (ECS Fargate)** and **GCP (Cloud Run)** with full IaC, CI/CD, environment separation, and operational documentation.

## Architecture Summary

| Component | AWS | GCP |
|-----------|-----|-----|
| **Compute** | ECS Fargate | Cloud Run |
| **Networking** | VPC + ALB + NAT | Cloud Run managed |
| **Region** | `us-east-1` | `us-central1` |
| **Scaling** | ECS Auto Scaling (CPU-based) | Auto (request-based, scale-to-zero) |
| **State** | S3 + DynamoDB locking | GCS with built-in locking |
| **CI/CD** | GitHub Actions → ECR → ECS | GitHub Actions → Artifact Registry → Cloud Run |

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
│   └── gcp/                  # GCP IaC (Cloud Run)
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
│   └── gcp.yml
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

# GCP (example: prod environment)
cd terraform/gcp
terraform init
terraform plan -var-file=envs/prod.tfvars
terraform apply -var-file=envs/prod.tfvars
```

## 📌 Deliverables
- **Architecture Documentation**: [docs/architecture.md](docs/architecture.md)
- **Deployment Guide**: [docs/deployment.md](docs/deployment.md)
- **Design Decisions**: [docs/decisions.md](docs/decisions.md)
- **Demo Video**: *(Link to be added)*
- **Live URLs**: *(To be populated after deployment)*

## 📖 Documentation Highlights
The [architecture document](docs/architecture.md) covers:
1. Cloud & Region Selection with justifications
2. Compute & Runtime Decisions (ECS Fargate vs Cloud Run)
3. Networking & Traffic Flow with diagrams
4. Environment Separation (dev/staging/prod)
5. Scalability & Availability strategy
6. Deployment & Rollback strategy
7. IaC & State Management
8. Security & Identity (least privilege)
9. Failure & Operational Thinking
10. Future Growth Scenarios
11. What We Intentionally Did NOT Do (and why)
