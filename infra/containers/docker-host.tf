resource "proxmox_virtual_environment_container" "docker_host" {
  node_name    = "homelab"
  vm_id        = 101
  unprivileged = true

  initialization {
    hostname = "docker-host"
    dns {
      servers = [split("/", var.pihole_ip)[0]]
    }
    ip_config {
      ipv4 {
        address = var.docker_host_ip
        gateway = var.gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type             = "debian"
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 1024
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  network_interface {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
  }

  console {
    enabled   = true
    tty_count = 2
    type      = "tty"
  }

  features {
    nesting = true
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      operating_system
    ]
  }
}
