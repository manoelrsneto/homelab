output "pihole_ip" {
  description = "Pi-hole IP"
  value       = module.containers.pihole_ip
}

output "homeassistant_ip" {
  description = "Home Assistant IP"
  value       = module.vms.homeassistant_ip
}