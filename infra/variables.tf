variable "proxmox_url" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox user"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "pihole_ip" {
  description = "Pi-hole static IP with CIDR ex: 192.168.68.200/24"
  type        = string
}

variable "docker_host_ip" {
  description = "Docker host static IP with CIDR ex: 192.168.68.201/24"
  type        = string
}