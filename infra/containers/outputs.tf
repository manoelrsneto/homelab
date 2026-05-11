output "pihole_ip" {
  value = proxmox_virtual_environment_container.pihole.initialization[0].ip_config[0].ipv4[0].address
}