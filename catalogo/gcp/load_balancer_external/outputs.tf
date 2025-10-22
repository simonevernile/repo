output "external_ip" {
  description = "External IP of the Network Load Balancer."
  value       = google_compute_address.ext_ip.address
}

output "tcp_forwarding_rules" {
  description = "Names of created external TCP forwarding rules."
  value       = [for _, v in google_compute_forwarding_rule.ext_tcp_fr : v.name]
}

output "udp_forwarding_rules" {
  description = "Names of created external UDP forwarding rules."
  value       = [for _, v in google_compute_forwarding_rule.ext_udp_fr : v.name]
}
