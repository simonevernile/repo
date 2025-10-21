output "internal_ip" {
  description = "Internal IP of the ILB."
  value       = google_compute_address.ilb_ip.address
}

output "tcp_forwarding_rules" {
  description = "Names of created internal TCP forwarding rules."
  value       = [for _, v in google_compute_forwarding_rule.tcp_fr : v.name]
}

output "udp_forwarding_rules" {
  description = "Names of created internal UDP forwarding rules."
  value       = [for _, v in google_compute_forwarding_rule.udp_fr : v.name]
}
