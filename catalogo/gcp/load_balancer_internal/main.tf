// Internal TCP/UDP Load Balancer (Regional)

resource "google_compute_address" "ilb_ip" {
  name         = "${var.name_prefix}-ilb-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = local.sub_self_link
  address      = var.address
  purpose      = "GCE_ENDPOINT"
  labels       = var.labels
}

// Backend: existing IG or placeholder
resource "google_compute_instance_group" "placeholder_ig" {
  count = var.backend_instance_group_zonal == null ? 1 : 0
  name  = "${var.name_prefix}-ilb-ig"
  zone  = var.backend_zone

  named_port {
    name = "tcp"
    port = 80
  }

  named_port {
    name = "udp"
    port = 80
  }

  description = "Placeholder unmanaged IG for ILB (empty by default)."
}

resource "google_compute_health_check" "ilb_hc_tcp" {
  name               = "${var.name_prefix}-ilb-hc-tcp"
  timeout_sec        = 5
  check_interval_sec = 5

  tcp_health_check { port = 80 }

  log_config { enable = true }
}

resource "google_compute_region_backend_service" "bes" {
  name                  = "${var.name_prefix}-ilb-bes"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.ilb_hc_tcp.self_link]

  backend {
    group          = var.backend_instance_group_zonal == null ? google_compute_instance_group.placeholder_ig[0].self_link : var.backend_instance_group_zonal
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_forwarding_rule" "tcp_fr" {
  for_each              = local.tcp_ports
  name                  = "${var.name_prefix}-ilb-tcp-${each.value}"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.ilb_ip.address
  ip_protocol           = "TCP"
  ports                 = [tostring(each.value)]
  backend_service       = google_compute_region_backend_service.bes.self_link
  network               = local.net_self_link
  subnetwork            = local.sub_self_link
  labels                = var.labels
}

resource "google_compute_forwarding_rule" "udp_fr" {
  for_each              = local.udp_ports
  name                  = "${var.name_prefix}-ilb-udp-${each.value}"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.ilb_ip.address
  ip_protocol           = "UDP"
  ports                 = [tostring(each.value)]
  backend_service       = google_compute_region_backend_service.bes.self_link
  network               = local.net_self_link
  subnetwork            = local.sub_self_link
  labels                = var.labels
}
