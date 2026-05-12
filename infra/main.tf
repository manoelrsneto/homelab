terraform {
  cloud {
    organization = "homelab-manoel"
    workspaces {
      name = "homelab"
    }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_url
  username = var.proxmox_user
  password = var.proxmox_password
  insecure = true
}

module "containers" {
  source             = "./containers"
  gateway            = var.gateway
  pihole_ip          = var.pihole_ip
  docker_host_ip     = var.docker_host_ip
  ansible_public_key = var.ansible_public_key
}

module "vms" {
  source           = "./vms"
  gateway          = var.gateway
  pihole_ip        = var.pihole_ip
  homeassistant_ip = var.homeassistant_ip
}
