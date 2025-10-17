resource "google_compute_forwarding_rule" "public_lb" {
  name        = "public-lb-rule"
  region      = var.region
  ip_address  = google_compute_address.public_lb.address
  target      = google_compute_target_pool.public_lb.self_link
  port_range  = "80"
}

resource "google_compute_address" "public_lb" {
  name = "public-lb-ip"
}

resource "google_compute_target_pool" "public_lb" {
  name    = "public-lb-pool"
  region  = var.region
}

resource "google_compute_forwarding_rule" "private_lb" {
  name        = "private-lb-rule"
  region      = var.region
  ip_address  = google_compute_address.private_lb.address
  target      = google_compute_target_pool.private_lb.self_link
  port_range  = "80"
  network     = var.network
}

resource "google_compute_address" "private_lb" {
  name    = "private-lb-ip"
  network = var.network
}

resource "google_compute_target_pool" "private_lb" {
  name    = "private-lb-pool"
  region  = var.region
}
