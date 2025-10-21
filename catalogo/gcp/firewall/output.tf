output "public_http_firewall" {
  value = try(google_compute_firewall.allow_public_http[0].id, null)
}

output "local_ssh_firewall" {
  value = google_compute_firewall.allow_local_ssh.id
}
