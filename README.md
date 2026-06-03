# daengglejeju-infra

> Terraform IaC for DaenggleJeju — single-command provisioning of the full AWS stack.

![Terraform](https://img.shields.io/badge/Terraform-1.x-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-ap--northeast--2-FF9900?logo=amazonaws)
![k3s](https://img.shields.io/badge/k3s-single--node-FFC61C?logo=k3s)

---

## Architecture

```mermaid
graph LR
  User -->|HTTPS| CF["CloudFront\n+ ACM"]
  CF -->|origin| R53["Route53\ndaengglejeju.cloud"]
  R53 -->|A record| EIP["Elastic IP"]

  subgraph VPC["VPC  ap-northeast-2"]
    EIP --> EC2["EC2 t3.small\nk3s"]
    EC2 --- SG["Security Group\n80 · 443 · 22"]
  end

  TF["terraform apply"] -->|remote backend + state lock| S3["S3\ntfstate"]
  TF --> VPC
```

---

## Stack

| Layer | Technology |
|---|---|
| IaC | Terraform |
| Compute | AWS EC2 t3.small (k3s single node) |
| CDN / TLS | CloudFront + ACM (us-east-1) |
| DNS | Route53 |
| State | S3 Remote Backend + native state locking |
| Container runtime | k3s (lightweight Kubernetes) |
| Ingress | Traefik Ingress Controller |

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.10
- AWS CLI configured (`aws configure`) with sufficient IAM permissions
- S3 bucket `daengglejeju-tfstate` already created (bootstrap once, not managed here)

---

## Quick Start

```bash
# 1. Initialize — downloads providers, connects to S3 backend
terraform init

# 2. Preview changes
terraform plan -var="ssh_public_key=$(cat ~/.ssh/id_ed25519.pub)"

# 3. Apply
terraform apply -var="ssh_public_key=$(cat ~/.ssh/id_ed25519.pub)"
```

Or use a `terraform.tfvars` file (excluded from git):

```hcl
# terraform.tfvars
ssh_public_key = "ssh-ed25519 AAAA..."
```

```bash
terraform apply
```

---

## Variables

| Name | Type | Default | Description |
|---|---|---|---|
| `aws_region` | string | `ap-northeast-2` | AWS region |
| `project` | string | `daengglejeju` | Resource name prefix |
| `domain` | string | `daengglejeju.cloud` | Service domain |
| `ec2_instance_type` | string | `t3.small` | k3s node instance type |
| `ec2_ami` | string | Ubuntu 24.04 LTS | AMI ID (ap-northeast-2) |
| `ssh_public_key` | string | — | **Required.** EC2 SSH public key |

---

## Outputs

| Name | Description |
|---|---|
| `ec2_public_ip` | k3s node Elastic IP |
| `cloudfront_domain` | CloudFront distribution domain |
| `cloudfront_id` | CloudFront distribution ID |
| `route53_nameservers` | NS records — point your registrar here |

---

## Resource Inventory

| Resource | Description |
|---|---|
| `aws_vpc` | /16 VPC |
| `aws_subnet` | Single public subnet |
| `aws_internet_gateway` + `aws_route_table` | Public internet access |
| `aws_security_group` | Ingress 80/443/22, egress all |
| `aws_instance` | t3.small, Ubuntu 24.04 |
| `aws_eip` | Static public IP attached to EC2 |
| `aws_acm_certificate` (us-east-1) | TLS cert for CloudFront |
| `aws_cloudfront_distribution` | CDN, HTTPS redirect, custom domain |
| `aws_route53_zone` + records | Hosted zone, apex/www A records, ACM CNAME |
| `aws_key_pair` | EC2 SSH key |

---

## State Management

Remote state is stored in S3 with native locking (`use_lockfile = true`). No DynamoDB table required.

```
s3://daengglejeju-tfstate/prod/terraform.tfstate
```

If a lock is stuck after an interrupted apply:

```bash
terraform force-unlock <LOCK_ID>
```

---

## What's Not Here

This repo provisions infrastructure only. Application deployment is handled separately:

- **CI/CD**: GitHub Actions (build) + ArgoCD (GitOps deploy) → [`DaenggleJeju`](https://github.com/kweonsikyung/DaenggleJeju)
- **Monitoring**: Prometheus + Grafana stack deployed as k3s workloads
