locals {
  proxmox_host    = regex("https?://([^:/]+)", var.proxmox_url)[0]
  haos_image_name = "haos_generic-x86-64-13.2.img"
  haos_image_path = "/var/lib/vz/template/iso/${local.haos_image_name}"
  haos_image_url  = "https://github.com/home-assistant/operating-system/releases/download/13.2/haos_generic-x86-64-13.2.img.xz"
}

resource "null_resource" "haos_image" {
  triggers = {
    image_name = local.haos_image_name
  }

  provisioner "local-exec" {
    environment = {
      SSHPASS = var.proxmox_password
    }
    command = <<-EOT
      sshpass -e ssh -o StrictHostKeyChecking=no root@${local.proxmox_host} \
        "[ -f ${local.haos_image_path} ] || (wget -q '${local.haos_image_url}' -O /tmp/haos.img.xz && unxz /tmp/haos.img.xz && mv /tmp/haos.img ${local.haos_image_path})"
    EOT
  }
}

resource "proxmox_virtual_environment_vm" "homeassistant" {
  node_name  = var.proxmox_node
  vm_id      = 102
  name       = "homeassistant"
  depends_on = [null_resource.haos_image]

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

  bios = "ovmf"

  efi_disk {
    datastore_id      = var.datastore_id
    type              = "4m"
    pre_enrolled_keys = false
  }

  disk {
    datastore_id = var.datastore_id
    file_id      = "local:iso/${local.haos_image_name}"
    interface    = "scsi0"
    size         = 32
    discard      = "on"
  }

  network_device {
    bridge   = "vmbr0"
    firewall = true
  }

  boot_order = ["scsi0"]

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [boot_order, efi_disk, bios]
  }
}
