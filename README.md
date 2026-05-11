# homelab

Personal homelab infrastructure managed as code.

## Stack

- **Proxmox** — hypervisor running on a Dell Inspiron 15 3567 (16GB RAM, 240GB SSD)
- **Terraform** — LXC container and VM provisioning
- **Ansible** — configuration management and app deployment
- **Docker Compose** — service orchestration
- **Caddy** — reverse proxy with automatic SSL
- **Tailscale** — remote access via mesh VPN
- **Cloudflare Tunnel** — secure external access via manoelneto.dev

## Services

| Service | Description |
|---|---|
| Pi-hole | Network-wide DNS ad blocking |
| Home Assistant | Home automation |
| Postgres | Central database |
| Grafana + Prometheus + Loki | Observability stack |
| Caddy | Reverse proxy |
| Uptime Kuma | Uptime monitoring |
| Homepage | Services dashboard |

## Prerequisites

- Terraform >= 1.0
- Proxmox VE >= 8.0
- Tailscale installed on Proxmox

## Usage

1. Copy the variables example:

```sh
cp infra/terraform.tfvars.example infra/terraform.tfvars
```

2. Fill in the values in `infra/terraform.tfvars`

3. Initialize and apply:

```sh
cd infra
terraform init
terraform apply
```

## Repository Structure

```
homelab/
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── containers/
│       └── pihole.tf
├── apps/
│   └── pihole/
│       └── docker-compose.yml
├── docs/
│   └── architecture.md
└── .github/
    └── workflows/
        └── deploy.yml
```

## Access

- **Local network** — via IP directly
- **Remote** — via Tailscale or Cloudflare Tunnel (manoelneto.dev)