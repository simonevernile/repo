output "external_ip" {
  description = "External IP of the Network Load Balancer."
  value       = google_compute_address.ext_ip.address
}

output "internal_ip" {
  description = "Internal IP of the Internal Load Balancer."
  value       = google_compute_address.ilb_ip.address
}

output "ext_tcp_forwarding_rules" {
  description = "Names of created external TCP forwarding rules."
  value       = [for k, v in google_compute_forwarding_rule.ext_tcp_fr : v.name]
}

output "ext_udp_forwarding_rules" {
  description = "Names of created external UDP forwarding rules."
  value       = [for k, v in google_compute_forwarding_rule.ext_udp_fr : v.name]
}

output "ilb_tcp_forwarding_rules" {
  description = "Names of created internal TCP forwarding rules."
  value       = [for k, v in google_compute_forwarding_rule.ilb_tcp_fr : v.name]
}

output "ilb_udp_forwarding_rules" {
  description = "Names of created internal UDP forwarding rules."
  value       = [for k, v in google_compute_forwarding_rule.ilb_udp_fr : v.name]
}
