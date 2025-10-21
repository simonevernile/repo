output "external_ip" {
  description = "The external IP address of the network load balancer."
  value       = google_compute_address.external_ip.address
}

output "external_tcp_forwarding_rules" {
  description = "Names of the created external TCP forwarding rules."
  value       = [for _, rule in google_compute_forwarding_rule.external_tcp : rule.name]
}

output "external_udp_forwarding_rules" {
  description = "Names of the created external UDP forwarding rules."
  value       = [for _, rule in google_compute_forwarding_rule.external_udp : rule.name]
}

output "internal_ip" {
  description = "The internal IP address of the regional load balancer."
  value       = google_compute_address.internal_ip.address
}

output "internal_tcp_forwarding_rules" {
  description = "Names of the created internal TCP forwarding rules."
  value       = [for _, rule in google_compute_forwarding_rule.internal_tcp : rule.name]
}

output "internal_udp_forwarding_rules" {
  description = "Names of the created internal UDP forwarding rules."
  value       = [for _, rule in google_compute_forwarding_rule.internal_udp : rule.name]
}
