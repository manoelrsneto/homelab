# homelab

![Deploy](https://img.shields.io/github/actions/workflow/status/manoelrsneto/homelab/deploy.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=Deploy)
![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Tailscale](https://img.shields.io/badge/Tailscale-242424?style=for-the-badge&logo=tailscale&logoColor=white)

> Personal homelab running on a repurposed laptop — fully automated from provisioning to deployment via CI/CD.

---

## Overview

This repo contains the full infrastructure-as-code for my homelab. Every change pushed to `main` automatically provisions infrastructure with Terraform and configures hosts with Ansible — no manual steps required.

**Hardware:** Dell Inspiron 15 3567 · 16GB RAM · 240GB SSD

## Architecture

```
GitHub Actions
    ├── Terraform  →  Proxmox (LXC provisioning)
    └── Ansible    →  Docker Host (configuration)
                          └── Docker Compose (services)

Tailscale mesh VPN
    ├── Proxmox host (subnet router → 192.168.68.0/24)
    └── Remote access from anywhere
```

## Stack

| Layer | Tool | Purpose |
|---|---|---|
| Hypervisor | Proxmox VE | LXC containers and VMs |
| Provisioning | Terraform | Infrastructure as code |
| Configuration | Ansible | Host setup and app deployment |
| Orchestration | Docker Compose | Service management |
| DNS | Pi-hole | Network-wide ad blocking |
| Reverse Proxy | Caddy | Automatic SSL termination |
| VPN | Tailscale | Secure remote access |
| Tunnel | Cloudflare Tunnel | External access via manoelneto.dev |

## Services

| Service | Description |
|---|---|
| Pi-hole | Network-wide DNS ad blocking |
| Home Assistant | Home automation |
| Postgres | Central database |
| Grafana + Prometheus + Loki | Observability stack |
| Uptime Kuma | Uptime monitoring |
| Homepage | Services dashboard |

## CI/CD Pipeline

Every push to `main` triggers:

1. **Terraform** — provisions or updates LXC containers on Proxmox
2. **Ansible** — installs Docker, clones this repo, applies configuration

Secrets (Proxmox credentials, SSH keys, Tailscale authkey) are stored in GitHub Actions secrets and never committed to the repo.

## Repository Structure

```
homelab/
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   └── containers/
│       ├── pihole.tf
│       └── docker-host.tf
├── ansible/
│   ├── inventory/
│   └── playbooks/
│       └── docker.yml
├── apps/
│   └── pihole/
│       └── docker-compose.yml
└── .github/
    └── workflows/
        └── deploy.yml
```

## Local Development

```sh
# Copy and fill in your variables
cp infra/terraform.tfvars.example infra/terraform.tfvars

# Provision infrastructure
cd infra
terraform init
terraform apply
```

## Access

- **Local** — direct IP on `192.168.68.0/24`
- **Remote** — via Tailscale or Cloudflare Tunnel (`manoelneto.dev`)
