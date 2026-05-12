# homelab

![Lint](https://img.shields.io/github/actions/workflow/status/manoelrsneto/homelab/lint.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=Lint)
![Infra](https://img.shields.io/github/actions/workflow/status/manoelrsneto/homelab/infra.yml?style=for-the-badge&logo=terraform&logoColor=white&label=Infra)
![Apps](https://img.shields.io/github/actions/workflow/status/manoelrsneto/homelab/apps.yml?style=for-the-badge&logo=ansible&logoColor=white&label=Apps)
![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Tailscale](https://img.shields.io/badge/Tailscale-242424?style=for-the-badge&logo=tailscale&logoColor=white)

> Personal homelab running on a repurposed laptop — fully automated from provisioning to deployment via CI/CD.

---

## Hardware

**Dell Inspiron 15 3567** · Intel i5-7200U · 16GB RAM · 240GB SSD · Proxmox VE 9.1

## Architecture

```
GitHub Actions
    ├── lint.yml   →  terraform fmt · tflint · ansible-lint · yamllint · actionlint
    ├── infra.yml  →  Proxmox (LXC + VM via Terraform)
    └── apps.yml   →  Docker Host (bootstrap + deploy via Ansible)
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
| Configuration | Ansible | Host bootstrap and service deployment |
| Orchestration | Docker Compose | Service management |
| DNS | Pi-hole | Network-wide ad blocking and local DNS |
| Reverse Proxy | Nginx Proxy Manager | SSL termination and domain routing |
| VPN | Tailscale | Secure remote access |
| Tunnel | Cloudflare Tunnel | External access via manoelneto.dev |
| Secrets | SOPS + age | Encrypted secrets committed to the repo |
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
| Nginx Proxy Manager | Reverse proxy with SSL |

## CI/CD Pipeline

Three independent workflows, each triggered only when relevant files change:

| Workflow | Trigger | Jobs |
|---|---|---|
| `lint.yml` | every push and PR | terraform fmt, tflint, ansible-lint, yamllint, actionlint |
| `infra.yml` | changes to `infra/**` | init → validate → plan → apply |
| `apps.yml` | changes to `apps/**`, `ansible/**`, `secrets/**` | decrypt secrets → bootstrap → deploy |

Infrastructure credentials (Proxmox, SSH keys, Tailscale authkey) live in GitHub Actions Secrets. Application secrets (DB passwords, service credentials) are encrypted with SOPS + age and committed to `secrets/apps.sops.yaml`.

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
│   │   ├── bootstrap.yml
│   │   └── deploy.yml
│   └── roles/docker/
├── apps/                   # Docker Compose — what runs as a service
│   ├── proxy/
│   ├── monitoring/
│   ├── uptime-kuma/
│   ├── homepage/
│   └── postgres/
├── secrets/                # SOPS — encrypted secrets
│   └── apps.sops.yaml
└── .github/workflows/
    ├── lint.yml
    ├── infra.yml
    └── apps.yml
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
