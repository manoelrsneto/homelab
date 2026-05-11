# Architecture

## Overview

```
                         Internet
                             │
                  Cloudflare Tunnel
                             │
                     manoelneto.dev
                             │
                  ┌──────────┴──────────┐
                  │        Caddy        │
                  │   (reverse proxy)   │
                  └──────────┬──────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
   grafana.manoelneto.dev  uptime.manoelneto.dev  home.manoelneto.dev
        Grafana              Uptime Kuma         Home Assistant
      (docker-host)        (docker-host)           (VM - HAOS)

                       Tailscale VPN
                             │
                     100.X.X.X
                             │
                  ┌──────────┴──────────┐
                  │       Proxmox       │
                  │   192.168.X.100     │
                  └──────────┬──────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
       Pi-hole          docker-host        home-assistant
   192.168.X.200      LXC (TBD IP)          VM (TBD IP)
       (LXC)          ├── Grafana             (HAOS)
                      ├── Prometheus
                      ├── Loki
                      ├── Caddy
                      ├── Uptime Kuma
                      ├── Homepage
                      └── Postgres
```

## Hardware

| Item | Spec |
|---|---|
| Model | Dell Inspiron 15 3567 |
| RAM | 16GB DDR4 2400MHz |
| Storage | 240GB SSD |
| Hypervisor | Proxmox VE 9.1 |

## Network

| Item | Value |
|---|---|
| Gateway | 192.168.X.1 |
| Subnet | 192.168.X.0/24 |
| DNS | Pi-hole (192.168.X.200) |

## Infrastructure

| Name | Type | ID | RAM | Disk |
|---|---|---|---|---|
| pihole | LXC | 100 | 512MB | 4GB |
| docker-host | LXC | TBD | 4GB | 80GB |
| home-assistant | VM | TBD | 2GB | 32GB |

## Design Decisions

**LXC over VMs (except Home Assistant)**
LXC containers have significantly lower RAM and disk overhead than full VMs, critical on a 240GB SSD. Home Assistant runs as a VM because HAOS requires direct hardware access and its own OS.

**All apps on a single docker-host LXC**
Running all Docker-based services on a single LXC is more resource-efficient than one LXC per service. Each app gets its own Docker Compose stack.

**Centralized Postgres**
A single Postgres instance serving multiple apps is more resource-efficient than one per app, and simplifies backup management.

**Caddy over Nginx**
Caddy handles SSL certificate management automatically via Let's Encrypt with zero manual configuration, ideal for a homelab setup.

**Tailscale for remote access**
Tailscale provides secure mesh VPN access without exposing any ports to the internet, complementing Cloudflare Tunnel for public-facing services.

**Cloudflare Tunnel for public access**
No open ports on the router. The tunnel is established outbound from the docker-host, keeping the network secure.