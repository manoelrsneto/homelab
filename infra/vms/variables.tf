variable "proxmox_url" {
  type = string
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "homeassistant_ip" {
  type = string
}
