output "rules" {
  description = "Map of rule name → full google_compute_firewall resource."
  value       = google_compute_firewall.rules
}

output "ids" {
  description = "Map of rule name → firewall resource ID."
  value       = { for k, v in google_compute_firewall.rules : k => v.id }
}

output "self_links" {
  description = "Map of rule name → self link."
  value       = { for k, v in google_compute_firewall.rules : k => v.self_link }
}
