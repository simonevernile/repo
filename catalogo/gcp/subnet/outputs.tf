output "subnets" {
  description = "Map of subnet name → full resource object."
  value       = google_compute_subnetwork.subnets
}

output "self_links" {
  description = "Map of subnet name → self link."
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.self_link }
}

output "ids" {
  description = "Map of subnet name → resource ID."
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.id }
}

output "ip_cidr_ranges" {
  description = "Map of subnet name → CIDR range."
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.ip_cidr_range }
}

output "secondary_ranges" {
  description = "Map of subnet name → list of {range_name, ip_cidr_range} secondary ranges."
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.secondary_ip_range }
}
