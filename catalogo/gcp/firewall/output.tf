output "ssh_firewall" {
  description = "ID of the SSH ingress rule."
  value       = google_compute_firewall.allow_local_ssh.id
}

output "public_http_firewall" {
  description = "ID of the public HTTP rule, or null when allow_http is false."
  value       = try(google_compute_firewall.allow_public_http[0].id, null)
}

output "public_https_firewall" {
  description = "ID of the public HTTPS rule, or null when allow_https is false."
  value       = try(google_compute_firewall.allow_public_https[0].id, null)
}

output "health_check_firewall" {
  description = "ID of the health-check ingress rule, or null when allow_health_checks is false."
  value       = try(google_compute_firewall.allow_health_checks[0].id, null)
}

output "custom_firewall_ids" {
  description = "Map of custom rule name → firewall ID."
  value       = { for k, v in google_compute_firewall.custom : k => v.id }
}
