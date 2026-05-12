output "pihole_ip" {
  description = "Pi-hole IP"
  value       = proxmox_virtual_environment_container.pihole.initialization[0].ip_config[0].ipv4[0].address
}

output "docker_host_ip" {
  description = "Docker host IP"
  value       = proxmox_virtual_environment_container.docker_host.initialization[0].ip_config[0].ipv4[0].address
}
