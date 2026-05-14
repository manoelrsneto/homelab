# homelab

![CI](https://img.shields.io/github/actions/workflow/status/manoelrsneto/homelab/ci.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=CI)
![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Tailscale](https://img.shields.io/badge/Tailscale-242424?style=for-the-badge&logo=tailscale&logoColor=white)

> Personal homelab running on a repurposed laptop — fully automated from provisioning to deployment via CI/CD.

---

## Hardware

**Dell Inspiron 15 3567** · Intel i3 · 16GB RAM · 240GB SSD · Proxmox VE 9.1

## Architecture

```
GitHub Actions (ci.yml)
    ├── lint     →  terraform fmt · tflint · ansible-lint · yamllint · actionlint
    ├── terraform →  Proxmox (LXC + VM via Terraform)  [needs: lint]
    └── bootstrap →  Docker Host (Docker install + Portainer)  [needs: lint]
                           └── Docker Compose stacks (one per service)

Tailscale mesh VPN
    └── Proxmox host (subnet router → 192.168.68.0/24)

Cloudflare Tunnel → manoelneto.dev → NPM → internal services
```

## Stack

| Layer | Tool | Purpose |
|---|---|---|
| Hypervisor | Proxmox VE | LXC containers and VMs |
| Provisioning | Terraform + TF Cloud | Infrastructure as code |
| Configuration | Ansible | Host bootstrap (Docker install + Portainer) |
| Orchestration | Docker Compose | Service management |
| DNS | Pi-hole | Network-wide ad blocking and local DNS |
| Reverse Proxy | Nginx Proxy Manager | SSL termination and domain routing |
| VPN | Tailscale | Secure remote access |
| Tunnel | Cloudflare Tunnel | External access via manoelneto.dev |
| App Management | Portainer | Docker UI — deploy stacks, manage env vars |
| Lint | tflint · ansible-lint · yamllint · actionlint | Code quality |

## Services

| Service | Description |
|---|---|
| Pi-hole | Network-wide DNS ad blocking |
| Home Assistant | Home automation (HAOS) |
| Postgres | Centralized database |
| Grafana + Prometheus + Loki | Observability stack |
| Uptime Kuma | Uptime monitoring |
| Homepage | Services dashboard |
| Portainer | Docker container management UI |
| Nginx Proxy Manager | Reverse proxy with SSL |

## CI/CD Pipeline

Single `ci.yml` workflow with path-based job gating:

| Job | Trigger | Needs |
|---|---|---|
| lint (5 jobs) | every push and PR | — |
| `terraform` | changes to `infra/**` | lint |
| `bootstrap` | changes to `apps/**`, `ansible/**` | lint |

Infrastructure credentials (Proxmox, SSH keys, Tailscale authkey) live in GitHub Actions Secrets. Application secrets (DB passwords, service credentials) are managed via Portainer's environment variable UI — no credentials in the repository.

## Repository Structure

```
homelab/
├── infra/                  # Terraform — what exists on Proxmox
│   ├── main.tf
│   ├── variables.tf
│   ├── pihole.tf
│   ├── docker-host.tf
│   └── homeassistant.tf
├── ansible/                # Ansible — how the OS is configured
│   ├── group_vars/
│   ├── inventory/
│   ├── playbooks/
│   │   └── bootstrap.yml
│   └── roles/docker/
├── apps/                   # Docker Compose — what runs as a service
│   ├── proxy/
│   ├── monitoring/
│   ├── uptime-kuma/
│   ├── homepage/
│   └── postgres/
├── secrets/                # SOPS structure (optional, for future use)
└── .github/workflows/
    └── ci.yml
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
