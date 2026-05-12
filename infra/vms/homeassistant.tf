resource "proxmox_virtual_environment_download_file" "haos_image" {
  content_type            = "iso"
  datastore_id            = "local"
  node_name               = "homelab"
  url                     = "https://github.com/home-assistant/operating-system/releases/download/13.2/haos_generic-x86-64-13.2.img.xz"
  file_name               = "haos_generic-x86-64-13.2.img"
  decompression_algorithm = "xz"
  overwrite               = false
}

resource "proxmox_virtual_environment_vm" "homeassistant" {
  node_name = "homelab"
  vm_id     = 102
  name      = "homeassistant"

  operating_system {
    type = "l26"
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.haos_image.id
    interface    = "scsi0"
    size         = 32
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge   = "vmbr0"
    firewall = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.homeassistant_ip
        gateway = var.gateway
      }
    }
    dns {
      servers = [split("/", var.pihole_ip)[0]]
    }
  }

  boot_order = ["scsi0"]

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [boot_order]
  }
}
