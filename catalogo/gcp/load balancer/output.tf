output "public_ip" {
  description = "The public IP address of the load balancer"
  value       = google_compute_address.public_lb.address
}

output "private_ip" {
  description = "The private IP address of the load balancer"
  value       = google_compute_address.private_lb.address
}
