# What We Did NOT Do & Why

## 1. Kubernetes (K8s) in AWS
**Decision**: Chose **ECS Fargate** over EKS.
**Reason**: 
- **Simplicity**: For a simple 2-container app, K8s introduces significant operational overhead (control plane management, node groups, complexity of manifests).
- **Cost**: EKS Control Plane costs ~$70/month + worker nodes. Fargate is pay-per-use and cheaper for low traffic.
- **Maintenance**: ECS requires less ongoing maintenance than a self-managed or even managed K8s cluster for this scale.

## 2. Kubernetes (AKS) in Azure
**Decision**: Chose **Azure Container Apps** over AKS.
**Reason**:
- **Simplicity**: Container Apps abstracts away all Kubernetes complexity while being built on top of it internally.
- **Cost**: AKS requires at least one node pool running at all times. Container Apps scales to zero — no cost during idle.
- **Operational Overhead**: No cluster upgrades, no node patching, no ingress controller management.

## 3. Complex Service Mesh (Istio/Linkerd)
**Decision**: Relied on **ALB** (AWS) and **Container Apps' built-in Envoy proxy** (Azure).
**Reason**: 
- **Overkill**: Service mesh adds observability and traffic control which are not needed for a simple frontend-backend communication.
- **Latency**: Adds sidecar proxy latency.

## 4. Multi-Region Deployment
**Decision**: Single region (`us-east-1` for AWS, `eastus` for Azure).
**Reason**: 
- **Cost/Complexity**: Data consistency across regions (database replication) is complex and expensive.
- **Requirement**: The assignment asked for deployment in two *clouds*, not necessarily multi-region active-active.

## 5. HTTPS/TLS on ALB (in AWS)
**Decision**: HTTP for AWS ALB.
**Reason**: 
- **Domain Requirement**: TLS requires a valid domain name and certificate (ACM).
- **Simplicity**: To keep the assignment easily reproducible without requiring the reviewer to own a domain or configure DNS.
- **Note**: Azure Container Apps provides HTTPS automatically with managed certificates — no extra configuration needed.

## 6. Persistent Database (RDS/Azure SQL)
**Decision**: No persistent database.
**Reason**: 
- **App Scope**: The provided backend is stateless and returns static JSON.
- **Cost/Time**: Setting up RDS adds cost and initialization time (approx. 15-20 mins) which slows down the review process.
