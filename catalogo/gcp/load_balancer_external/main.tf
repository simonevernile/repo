resource "google_compute_address" "ext_ip" {
  name   = "${var.name_prefix}-ext-ip"
  region = var.region
  labels = var.labels
}

resource "google_compute_http_health_check" "ext_hc_http" {
  name               = "${var.name_prefix}-ext-hc-http"
  timeout_sec        = 5
  check_interval_sec = 5
  port               = 80
}

resource "google_compute_target_pool" "ext_pool" {
  name          = "${var.name_prefix}-ext-pool"
  region        = var.region
  health_checks = [google_compute_http_health_check.ext_hc_http.self_link]
  instances     = var.target_pool_instances
}

resource "google_compute_forwarding_rule" "ext_tcp_fr" {
  for_each    = toset(var.tcp_ports)
  name        = "${var.name_prefix}-ext-tcp-${each.value}"
  region      = var.region
  ip_address  = google_compute_address.ext_ip.address
  ip_protocol = "TCP"
  port_range  = each.value
  target      = google_compute_target_pool.ext_pool.self_link
  labels      = var.labels
}

resource "google_compute_forwarding_rule" "ext_udp_fr" {
  for_each    = toset(var.udp_ports)
  name        = "${var.name_prefix}-ext-udp-${each.value}"
  region      = var.region
  ip_address  = google_compute_address.ext_ip.address
  ip_protocol = "UDP"
  port_range  = each.value
  target      = google_compute_target_pool.ext_pool.self_link
  labels      = var.labels
}