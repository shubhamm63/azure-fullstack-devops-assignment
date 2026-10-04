# Azure Full-Stack DevOps Assignment

A React + Node.js + PostgreSQL application deployed on Azure with Terraform, Docker, ACR, GitHub Actions, and Azure Monitor.

## Architecture

```text
Internet
   |
Application Gateway
   |
Frontend App Service
   |
Backend App Service
   |
PostgreSQL Flexible Server
   |
Private VNet
```

Supporting services:

* Azure Container Registry for Docker images
* Terraform with Azure Storage remote state
* Application Insights + Log Analytics for monitoring and logs
* Managed Identities for ACR access
* GitHub Actions for CI/CD

## Azure Infrastructure

Terraform provisions:

* VNet with separate subnets and NSGs
* Application Gateway
* Frontend and backend App Services
* Azure Container Registry
* PostgreSQL Flexible Server with private access
* Private DNS
* Managed Identities and RBAC
* Application Insights and Log Analytics

The Terraform state is stored remotely in Azure Storage with state locking.

## CI/CD

GitHub Actions runs on pull requests and pushes to `main`.

Pipeline flow:

```text
PR
 ↓
Lint + Build + Dependency Audit
 ↓
Docker Build
 ↓
Trivy Scan
 ↓
Push Images to ACR
 ↓
Staging Deployment
 ↓
Manual Production Approval
 ↓
Production Deployment
```

GitHub Actions uses Azure OIDC authentication instead of storing long-lived Azure credentials.

Docker images are tagged using the Git commit SHA so deployments can be traced back to a specific commit.

## Monitoring

Azure Monitor, Application Insights and Log Analytics are used for monitoring and centralized logs.

Two dashboards were created:

* **Frontend:** Requests, CPU and Memory
* **Backend:** Requests, CPU and Memory

PostgreSQL has automated backups enabled with 7-day retention.

## Security

* PostgreSQL is privately accessible inside the VNet.
* TLS is required for database connections.
* App Services use Managed Identity with `AcrPull` permissions.
* ACR admin access is disabled.
* GitHub Actions uses OIDC.
* Docker images are scanned with Trivy.
* Sensitive Terraform variables are not committed to Git.

## Cost Optimization

This is an assignment/demo environment, so smaller Azure SKUs were selected where practical:

* App Service B1
* PostgreSQL B_Standard_B1ms
* Basic ACR
* Limited Application Gateway autoscaling
* 30-day Log Analytics retention

## Challenges

A few issues came up during implementation, including Azure regional availability, GitHub OIDC subject matching, App Service container configuration, and Terraform detecting CI/CD-managed image tags.

These were resolved by moving the deployment to Central India, configuring the correct GitHub federated credentials, updating the container configuration, and using Terraform lifecycle rules for CI/CD-managed image versions.

## Useful Commands

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform output
```

Local application:

```bash
docker compose up --build
```

Frontend: `http://localhost:4172`

Backend: `http://localhost:7999`
