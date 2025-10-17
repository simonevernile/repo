resource "google_compute_firewall" "allow_public_http" {
  name    = "allow-public-http"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.target_tags
}

resource "google_compute_firewall" "allow_local_ssh" {
  name    = "allow-local-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.local_range
  target_tags   = var.ssh_tags
}

resource "google_compute_firewall" "allow_public_https" {
  count   = var.allow_https ? 1 : 0
  name    = "allow-public-https"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.target_tags
}

resource "google_compute_firewall" "allow_public_http" {
  count   = var.allow_http ? 1 : 0
  name    = "allow-public-http"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.target_tags
}
