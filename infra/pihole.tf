resource "proxmox_virtual_environment_container" "pihole" {
  node_name    = var.proxmox_node
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

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type             = "debian"
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
    swap      = 512
  }

  disk {
    datastore_id = var.datastore_id
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
    prevent_destroy = true
    ignore_changes  = [operating_system]
  }
}
