resource "proxmox_virtual_environment_container" "pihole" {
  node_name    = "homelab"
  vm_id        = 100
  unprivileged = true

  initialization {
    hostname = "pihole"
    dns {
      servers = ["1.1.1.1"]
    }
    ip_config {
      ipv4 {
        address = var.pihole_ip
        gateway = var.gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
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
    ignore_changes = [
      operating_system
    ]
  }
}