output "public_http_firewall" {
  value = google_compute_firewall.allow_public_http.id
}

output "local_ssh_firewall" {
  value = google_compute_firewall.allow_local_ssh.id
}
