# Architecture

## Overview

```
                         Internet
                             │
                  Cloudflare Tunnel
                             │
                     manoelneto.dev
                             │
              ┌──────────────┴──────────────┐
              │     Nginx Proxy Manager     │
              │       (docker-host)         │
              └──────────────┬──────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
grafana.manoelneto.dev  uptime.manoelneto.dev  home.manoelneto.dev
      Grafana              Uptime Kuma          Home Assistant
   (docker-host)          (docker-host)          (VM - HAOS)

                       Tailscale VPN
                             │
                       100.X.X.X
                             │
              ┌──────────────┴──────────────┐
              │           Proxmox           │
              │       192.168.68.100        │
              └──────────────┬──────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
     Pi-hole           docker-host          homeassistant
 192.168.68.200      192.168.68.201         192.168.68.202
     LXC 100            LXC 101            VM 102 (HAOS)
                    ├── Portainer
                    ├── NPM
                    ├── Grafana
                    ├── Prometheus
                    ├── Loki + Promtail
                    ├── Uptime Kuma
                    ├── Homepage
                    └── Postgres
```

## Hardware

| Item | Spec |
|---|---|
| Model | Dell Inspiron 15 3567 |
| CPU | Intel Core i3 |
| RAM | 16GB DDR4 2400MHz |
| Storage | 240GB SSD |
| Hypervisor | Proxmox VE 9.1 |

## Network

| Item | Value |
|---|---|
| Gateway | 192.168.68.1 |
| Subnet | 192.168.68.0/24 |
| DNS | Pi-hole (192.168.68.200) |

## Infrastructure

| Name | Type | ID | IP | RAM | Disk |
|---|---|---|---|---|---|
| pihole | LXC | 100 | 192.168.68.200 | 512MB | 4GB |
| docker-host | LXC | 101 | 192.168.68.201 | 4GB | 80GB |
| homeassistant | VM | 102 | 192.168.68.202 | 2GB | 32GB |

## Resource Budget

| | Proxmox OS | pihole | docker-host | homeassistant | Free |
|---|---|---|---|---|---|
| RAM (16GB) | ~2GB | 512MB | 4GB | 2GB | ~7.5GB |
| Disk (240GB) | ~20GB | 4GB | 80GB | 32GB | ~104GB |

## Apps Layer

Each service has its own Docker Compose stack under `apps/`. All stacks share the `homelab` Docker network. Portainer manages deployment and lifecycle of all stacks after the initial bootstrap.

| Stack | Port | Description |
|---|---|---|
| portainer | 9000, 9443 | Container management UI |
| postgres | 5432 (internal) | Centralized database |
| monitoring | 3000, 9090, 3100 | Grafana + Prometheus + Loki + Promtail |
| proxy | 80, 443, 81 | Nginx Proxy Manager |
| uptime-kuma | 3001 | Uptime monitoring |
| homepage | 3002 | Services dashboard |

## CI/CD

Single `ci.yml` workflow. Lint jobs always run; deploy jobs only run when relevant paths change and require lint to pass first.

| Job | Trigger | Needs |
|---|---|---|
| terraform-fmt, tflint, ansible-lint, yamllint, actionlint | every push and PR | — |
| `terraform` | changes to `infra/**` | lint |
| `bootstrap` | changes to `apps/**`, `ansible/**` | lint |

## Secrets

Application secrets (DB passwords, service credentials) are managed through Portainer's environment variable UI per stack — no credentials are stored in the repository or passed through CI.

Infrastructure credentials (Proxmox, SSH keys, Tailscale authkey) live in GitHub Actions Secrets.

## Design Decisions

**LXC over VMs (except Home Assistant)**
LXC containers have significantly lower RAM and disk overhead than full VMs, which is critical on a 240GB SSD. Home Assistant runs as a VM because HAOS requires direct hardware access and its own OS.

**All apps on a single docker-host LXC**
Running all Docker-based services on a single LXC is more resource-efficient than one LXC per service. Each app gets its own Docker Compose stack with isolated networks and volumes.

**Centralized Postgres**
A single Postgres instance serving multiple apps is more resource-efficient and simplifies backup management.

**NPM as reverse proxy**
Nginx Proxy Manager provides a web UI for managing proxy hosts and SSL certificates without editing config files manually — ideal for a homelab where configuration changes frequently.

**Tailscale for remote access**
Tailscale provides secure mesh VPN access without exposing any ports to the internet, complementing Cloudflare Tunnel for public-facing services.

**Cloudflare Tunnel for public access**
No open ports on the router. The tunnel is established outbound from the docker-host, keeping the network secure.

**Portainer for app management**
Portainer provides a web UI for deploying and managing Docker Compose stacks, monitoring container health, and managing environment variables per stack. This removes the need for Ansible to handle app deployment and keeps credentials out of the repository entirely.
