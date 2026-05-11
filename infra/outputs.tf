output "pihole_ip" {
  description = "Pi-hole IP"
  value       = module.containers.pihole_ip
}