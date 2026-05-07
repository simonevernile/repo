output "name" {
  description = "Network name."
  value       = google_compute_network.vpc.name
}

output "id" {
  description = "Network resource ID."
  value       = google_compute_network.vpc.id
}

output "self_link" {
  description = "Self link of the network."
  value       = google_compute_network.vpc.self_link
}

output "gateway_ipv4" {
  description = "IPv4 gateway address of the network."
  value       = google_compute_network.vpc.gateway_ipv4
}

output "private_service_access_range" {
  description = "Reserved range for Private Service Access (when enabled)."
  value       = try(google_compute_global_address.private_service_access[0].address, null)
}

output "private_service_access_connection" {
  description = "Service Networking peering connection ID (when enabled)."
  value       = try(google_service_networking_connection.private_service_access[0].id, null)
}
