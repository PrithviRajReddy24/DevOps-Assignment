# DevOps Assignment — Infrastructure Architecture Documentation

## Table of Contents
1. [Cloud & Region Selection](#1-cloud--region-selection)
2. [Compute & Runtime Decisions](#2-compute--runtime-decisions)
3. [Networking & Traffic Flow](#3-networking--traffic-flow)
4. [Environment Separation](#4-environment-separation)
5. [Scalability & Availability](#5-scalability--availability)
6. [Deployment Strategy](#6-deployment-strategy)
7. [Infrastructure as Code & State Management](#7-infrastructure-as-code--state-management)
8. [Security & Identity](#8-security--identity)
9. [Failure & Operational Thinking](#9-failure--operational-thinking)
10. [Future Growth Scenario](#10-future-growth-scenario)
11. [What We Did NOT Do](#11-what-we-did-not-do)

---

## 1. Cloud & Region Selection

### AWS — `us-east-1` (N. Virginia)
| Factor | Reasoning |
|--------|-----------|
| **Cost** | Lowest pricing across most AWS services; largest spot market |
| **Feature Availability** | First region to receive new services and features |
| **Latency** | Optimized for North American users; good global peering |
| **Tradeoff** | High demand can occasionally cause capacity issues; more blast radius during regional outages (rare but impactful due to many services depending on us-east-1) |

### GCP — `us-central1` (Iowa)
| Factor | Reasoning |
|--------|-----------|
| **Cost** | Competitive pricing; Iowa has low energy costs |
| **Sustainability** | Google-certified low-carbon region |
| **Latency** | Central US location provides balanced latency coast-to-coast |
| **Tradeoff** | Slightly higher latency to East Coast users vs `us-east4`, but better cost profile |

**Why different regions?** The assignment explicitly requires infrastructure choices to differ. Using different regions demonstrates multi-cloud thinking, avoids "copy-paste" architecture, and shows awareness of provider-specific strengths.

---

## 2. Compute & Runtime Decisions

### AWS — ECS Fargate (Managed Containers)
| Criteria | Assessment |
|----------|------------|
| **Application Needs** | Simple stateless containers — perfect fit for Fargate |
| **Operational Complexity** | No EC2 instances to manage, no OS patching, no capacity planning |
| **Scalability** | Task-level auto-scaling via Application Auto Scaling |
| **Cost** | Pay per vCPU/memory/second — ~$0.04/hour for our workload |

**Why NOT Kubernetes (EKS)?**
- The app is 2 simple containers. EKS control plane costs ~$73/month before any workload runs.
- K8s adds YAML complexity (Deployments, Services, Ingress, ConfigMaps) that provides no benefit at this scale.
- ECS provides equivalent container orchestration with native AWS integration.

**Why NOT VMs (EC2)?**
- EC2 requires OS management, patching, and capacity planning.
- Over-provisioned for a lightweight API + static frontend.

### GCP — Cloud Run (Serverless Containers)
| Criteria | Assessment |
|----------|------------|
| **Application Needs** | Stateless HTTP services — Cloud Run's exact use case |
| **Operational Complexity** | Zero infrastructure management; fully serverless |
| **Scalability** | Automatic scale-to-zero and scale-up based on requests |
| **Cost** | Pay per request + compute time — effectively free for low traffic |

**Why Cloud Run over GKE?** Same reasoning as Fargate vs EKS — this app doesn't warrant Kubernetes overhead. Cloud Run provides instant deployments with zero cluster management.

**Deliberate difference from AWS:** Cloud Run (serverless, scale-to-zero) vs ECS Fargate (always-on containers) demonstrates understanding of different compute paradigms and their tradeoffs.

---

## 3. Networking & Traffic Flow

### AWS Architecture
```
                    Internet
                       │
                       ▼
              ┌────────────────┐
              │  Application   │
              │ Load Balancer  │  ← Public Subnet
              │   (ALB)        │
              └───────┬────────┘
                      │
          ┌───────────┴───────────┐
          │                       │
    ┌─────▼─────┐          ┌─────▼─────┐
    │ /api/*    │          │ /* (default)│
    │           │          │            │
    ▼           │          ▼            │
┌───────────┐   │    ┌───────────┐     │
│ Backend   │   │    │ Frontend  │     │
│ ECS Task  │   │    │ ECS Task  │     │
│ (Private) │   │    │ (Private) │     │
└───────────┘   │    └───────────┘     │
                │                      │
         Private Subnet           Private Subnet
          (AZ-a)                    (AZ-b)
```

- **ALB**: Only public-facing component. Routes `/api/*` to backend, everything else to frontend.
- **ECS Tasks**: Run in **private subnets** — no direct internet access.
- **NAT Gateway**: Allows private subnets to pull Docker images from ECR.
- **Security Groups**: ALB allows port 80 inbound from `0.0.0.0/0`; ECS tasks only accept traffic from the ALB security group.

### GCP Architecture
```
                    Internet
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
    ┌───────────┐            ┌───────────┐
    │ Cloud Run │            │ Cloud Run │
    │ Frontend  │───────────▶│ Backend   │
    │ (Public)  │  API calls │ (Public)  │
    └───────────┘            └───────────┘
```

- **Cloud Run**: Each service gets its own HTTPS URL automatically.
- **Frontend → Backend**: The frontend makes client-side API calls to the backend URL (injected at build time via `NEXT_PUBLIC_API_URL`).
- **Security**: IAM-based access control. Both services are set to `allUsers` for public access; in production, you'd restrict the backend to only accept traffic from the frontend's service account.

---

## 4. Environment Separation

Each cloud has three environments: **dev**, **staging**, **prod**

### AWS Environment Differences
| Aspect | Dev | Staging | Prod |
|--------|-----|---------|------|
| VPC CIDR | `10.0.0.0/16` | `10.1.0.0/16` | `10.2.0.0/16` |
| ECS Desired Count | 1 | 1 | 2 |
| Auto-Scale Min | 1 | 1 | 2 |
| Auto-Scale Max | 2 | 2 | 4 |
| Task CPU | 256 | 256 | 256 |
| Task Memory | 512 | 512 | 512 |

### GCP Environment Differences
| Aspect | Dev | Staging | Prod |
|--------|-----|---------|------|
| Cloud Run Min Instances | 0 | 0 | 1 |
| Cloud Run Max Instances | 2 | 5 | 10 |
| Concurrency | 80 | 80 | 80 |

### How Isolation Works
- **Terraform Workspaces + tfvars**: Each environment uses a separate `.tfvars` file (`envs/dev.tfvars`, `envs/staging.tfvars`, `envs/prod.tfvars`).
- **State Isolation**: Each environment's state is stored under a different key prefix in the remote backend.
- **Resource Naming**: All resources are prefixed with `{app_name}-{environment}-` to prevent naming collisions.
- **Separate VPC CIDRs**: Environments use distinct CIDR ranges to enable VPC peering if ever needed.

### Deployment command per environment:
```bash
# AWS
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars

# GCP
terraform plan -var-file=envs/prod.tfvars
terraform apply -var-file=envs/prod.tfvars
```

---

## 5. Scalability & Availability

### What Scales Automatically
| Component | AWS | GCP |
|-----------|-----|-----|
| **Backend** | ECS Auto Scaling (CPU > 70% → add task) | Cloud Run (automatic, per-request) |
| **Frontend** | ECS Auto Scaling (CPU > 70% → add task) | Cloud Run (automatic, per-request) |
| **Load Balancer** | ALB scales automatically | Built into Cloud Run |

### What Does NOT Scale Automatically (and why)
- **NAT Gateway (AWS)**: Single NAT per environment for cost. In production, you'd deploy one per AZ for HA. A NAT failure means private subnet containers can't pull images or reach external services.
- **Terraform State Backend**: S3/GCS buckets scale automatically, but DynamoDB lock table throughput may need adjustment under heavy concurrent `terraform apply` load.

### Traffic Spike Handling
- **AWS**: Scaling policy triggers at 70% CPU. Cool-down of 60s for scale-out, 300s for scale-in. Max of 4 tasks in prod prevents runaway costs.
- **GCP**: Cloud Run handles spikes natively — new instances spin up in ~1-2 seconds. Scale-to-zero during idle periods saves cost.

### Minimum Availability Guarantees
- **AWS**: Multi-AZ deployment (2 AZs). If one AZ goes down, the other AZ's tasks continue serving through the ALB.
- **GCP**: Cloud Run provides regional availability with automatic redundancy within the region.

---

## 6. Deployment Strategy

### What Happens During a Deployment

**AWS (ECS Fargate):**
1. CI/CD builds new Docker image, pushes to ECR.
2. New ECS Task Definition revision is registered.
3. ECS Service performs **rolling update**: starts new tasks, waits for health checks, then drains old tasks.
4. ALB health checks ensure only healthy tasks receive traffic.
5. **Expected downtime**: Zero (rolling deployment).

**GCP (Cloud Run):**
1. CI/CD builds new Docker image, pushes to Artifact Registry.
2. Cloud Run creates a new revision.
3. Traffic is shifted to the new revision (100% by default).
4. Old revision is kept for instant rollback.
5. **Expected downtime**: Zero (blue-green by default).

### Rollback Strategy
- **AWS**: Re-deploy the previous ECS Task Definition revision. CI/CD can revert the git commit to trigger a rebuild.
- **GCP**: `gcloud run services update-traffic --to-revisions=PREVIOUS_REVISION=100` — instant rollback without rebuilding.
- **Infrastructure**: `terraform apply` with previous state or revert the Terraform code commit.

### Failure During Deploy
- **AWS**: If new tasks fail health checks, ECS stops the deployment and keeps old tasks running (circuit breaker).
- **GCP**: If the new revision fails health checks, Cloud Run does not route traffic to it.

---

## 7. Infrastructure as Code & State Management

### Tool Choice: Terraform
- Mature, multi-cloud support.
- Declarative HCL syntax.
- Rich provider ecosystem for both AWS and GCP.

### State Storage
| Provider | Backend | Bucket/Table |
|----------|---------|--------------|
| AWS | S3 + DynamoDB | `devops-assignment-tf-state-prithvirajreddy` / `devops-assignment-tf-lock` |
| GCP | GCS | `devops-assignment-tf-state-prithvirajreddy` |

### State Isolation Per Environment
Each environment uses a separate state file via Terraform workspace or backend key configuration:
```hcl
# AWS Backend
backend "s3" {
  bucket = "devops-assignment-tf-state-prithvirajreddy"
  key    = "aws/terraform.tfstate"  # Would be "aws/dev/terraform.tfstate" per env
}
```

### Locking
- **AWS**: DynamoDB-based state locking prevents concurrent `terraform apply` operations from corrupting state.
- **GCP**: GCS provides built-in object locking for Terraform state.

### Recovery Considerations
- S3 bucket has versioning enabled — previous state versions can be recovered.
- GCS bucket has object versioning — same recovery capability.
- State files should never be manually edited. If state corruption occurs, use `terraform state` subcommands to repair.

---

## 8. Security & Identity

### Deployment Identity (CI/CD)
- **AWS**: GitHub Actions uses `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` stored in GitHub Secrets. In production, you'd use **OIDC federation** to avoid long-lived credentials.
- **GCP**: GitHub Actions uses a GCP Service Account JSON key stored in `GCP_CREDENTIALS` secret. Same recommendation for OIDC in production.

### Human Access Control
- **AWS**: IAM users/roles with MFA. Developers get read-only access to production; only CI/CD can deploy.
- **GCP**: IAM roles with Google Workspace identity. Principle of least privilege.

### Secret Storage & Injection
- **GitHub Secrets**: All sensitive values (`AWS_SECRET_ACCESS_KEY`, `GCP_CREDENTIALS`, `NEXT_PUBLIC_API_URL`).
- **Runtime**: Environment variables injected via ECS Task Definitions and Cloud Run service configs.
- **Never in**: Git repos, Docker images, CI logs.

### Least Privilege
- ECS Task Execution Role has only `AmazonECSTaskExecutionRolePolicy` (pull images, write logs).
- Cloud Run Service Account has only `roles/run.invoker`.

---

## 9. Failure & Operational Thinking

### Smallest Failure Unit
| Platform | Failure Unit | Impact |
|----------|-------------|--------|
| AWS | Single ECS Task (container) | One task out of N stops serving. ALB routes to healthy tasks. |
| GCP | Single Cloud Run instance | Cloud Run automatically replaces it. |

### What Breaks First
- **AWS**: ECS Task OOM kill (memory limit exceeded) or container crash. The ALB health check marks it unhealthy.
- **GCP**: Cloud Run instance hits memory limit or request timeout (300s default).

### What Self-Recovers
- **ECS**: Failed tasks are automatically replaced by the ECS Service scheduler.
- **Cloud Run**: Failed instances are automatically replaced. New instances spin up per request.

### What Requires Human Intervention
- **Terraform state corruption** (rare, requires manual state surgery).
- **Cloud provider quota limits** (need to request increase).
- **Application-level bugs** (incorrect API responses, logic errors) — these pass health checks but produce wrong results.
- **Certificate/domain issues** (if TLS is configured).

### Alerting Philosophy
**What is actionable:**
- 5XX error rate > 5% over 5 minutes → Alert on-call (P1)
- Health check failures for > 2 minutes → Alert on-call (P1)
- CPU sustained > 90% for 15 minutes → Alert team (P2)
- Deployment failure → Alert team on Slack (P2)

**What wakes someone up at 2 AM:**
- All tasks/instances down (complete outage)
- 5XX error rate > 50%
- Data breach / unauthorized access alerts

**What does NOT wake someone up:**
- Single task restart (self-heals)
- Auto-scaling events (expected behavior)
- Dev/staging environment issues

---

## 10. Future Growth Scenario

### Traffic Increases 10×
| What Changes | What Stays |
|-------------|------------|
| Auto-scaling max limits increase (4 → 40 in AWS) | VPC architecture stays the same |
| Consider adding CloudFront CDN for static assets | Terraform module structure unchanged |
| GCP Cloud Run handles this natively | Docker images unchanged |
| ALB may need to be pre-warmed for sudden spikes | CI/CD pipeline unchanged |

### New Backend Service Added
| What Changes | What Stays |
|-------------|------------|
| New ECS Task Definition + Service | Existing services unaffected |
| New ALB listener rule for routing | VPC and networking unchanged |
| New Cloud Run service in GCP | State management approach is identical |
| New CI/CD workflow or job added | Docker build process is templated |

### Client Demands Stricter Isolation
| What Changes | What Stays |
|-------------|------------|
| Dedicated VPC or AWS account per client | Terraform modules can be reused as-is |
| Private Link / VPC endpoints for internal traffic | CI/CD pipeline structure unchanged |
| Dedicated Cloud Run service with VPC connector | Dockerfile approach unchanged |

### Client Demands Region-Specific Data
| What Changes | What Stays |
|-------------|------------|
| Multi-region deployment required | Core Terraform modules are region-agnostic |
| Database with regional replication (RDS/Cloud SQL) | Application code unchanged (stateless) |
| Region-based routing (Route53 geolocation / GCP Load Balancer) | Docker images are region-agnostic |

### Which Early Decisions Help
- **Stateless application**: Makes horizontal scaling and multi-region trivial.
- **IaC with variables**: Adding a new environment or region is just a new tfvars file.
- **Fargate/Cloud Run**: No node management as we scale up.

### Which Early Decisions Hurt
- **Single NAT Gateway**: Would need one per AZ at higher scale.
- **Build-time API URL**: Requires rebuilding frontend image per environment. Runtime injection would be more flexible.
- **No service mesh**: At 10× scale with multiple services, service-to-service observability becomes important.

---

## 11. What We Did NOT Do

### 1. Kubernetes (EKS/GKE)
**Why not**: Two-container app doesn't justify K8s complexity. Control plane costs ($73/month EKS, $0-$73 GKE) and operational overhead (RBAC, NetworkPolicies, Ingress controllers) provide no benefit at this scale. Using K8s here would be resume-driven development.

### 2. HTTPS/TLS
**Why not**: Requires a registered domain name and DNS configuration. For a reproducible assignment, HTTP keeps it simple. In production, ACM (AWS) and Google-managed certificates (GCP) would be used.

### 3. Multi-Region Deployment
**Why not**: Data consistency complexity (CAP theorem), cost multiplication, and no stated latency requirement. The assignment asked for two *clouds*, not two regions.

### 4. Database (RDS/Cloud SQL)
**Why not**: The app is stateless. Adding a database would increase cost, deployment time (~15 min for RDS), and complexity without serving the application's actual needs.

### 5. Service Mesh (Istio/Linkerd)
**Why not**: Two services communicating via HTTP don't need sidecar proxies, mTLS, or traffic policies. These become valuable at 10+ services.

### 6. Custom Domain & DNS
**Why not**: Requires domain ownership. ALB DNS name and Cloud Run URLs are sufficient for demonstrating the architecture.

### 7. Centralized Logging (ELK/Loki)
**Why not**: CloudWatch (AWS) and Cloud Logging (GCP) provide sufficient logging for this scale. A dedicated logging stack adds cost and maintenance.

### 8. Chaos Engineering
**Why not**: While valuable, introduces risk in a demo environment. Failure scenarios are documented theoretically instead.

### 9. Cost Alerts / Budgets
**Why not**: Not implemented in Terraform, but would use AWS Budgets and GCP Billing Alerts in production.

### 10. WAF (Web Application Firewall)
**Why not**: The application has no user input or database — the attack surface is minimal. WAF would be important for applications handling sensitive data.

---

*This document is intended to be transferred to Google Docs for reviewer commenting. All diagrams can be enhanced using draw.io or Lucidchart.*
