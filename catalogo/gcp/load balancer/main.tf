// External TCP/UDP Network Load Balancer (legacy target pool)

resource "google_compute_address" "external_ip" {
  name   = "${var.name_prefix}-ext-ip"
  region = var.region
  labels = var.labels
}

resource "google_compute_health_check" "external_tcp" {
  name               = "${var.name_prefix}-ext-hc-tcp"
  timeout_sec        = 5
  check_interval_sec = 5

  tcp_health_check {
    port = 80
  }

  log_config {
    enable = true
  }

  labels = var.labels
}

resource "google_compute_target_pool" "external" {
  name          = "${var.name_prefix}-ext-pool"
  region        = var.region
  health_checks = [google_compute_health_check.external_tcp.self_link]
  instances     = var.target_pool_instances
}

resource "google_compute_forwarding_rule" "external_tcp" {
  for_each    = local.external_tcp_ports
  name        = "${var.name_prefix}-ext-tcp-${each.value}"
  region      = var.region
  ip_address  = google_compute_address.external_ip.address
  ip_protocol = "TCP"
  port_range  = tostring(each.value)
  target      = google_compute_target_pool.external.self_link
  labels      = var.labels
}

resource "google_compute_forwarding_rule" "external_udp" {
  for_each    = local.external_udp_ports
  name        = "${var.name_prefix}-ext-udp-${each.value}"
  region      = var.region
  ip_address  = google_compute_address.external_ip.address
  ip_protocol = "UDP"
  port_range  = tostring(each.value)
  target      = google_compute_target_pool.external.self_link
  labels      = var.labels
}

// Internal TCP/UDP Load Balancer (regional backend service)

resource "google_compute_address" "internal_ip" {
  name         = "${var.name_prefix}-ilb-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = local.subnetwork_self_link
  address      = var.internal_address
  purpose      = "GCE_ENDPOINT"
  labels       = var.labels
}

resource "google_compute_instance_group" "placeholder_ig" {
  count = var.backend_instance_group_zonal == null ? 1 : 0
  name  = "${var.name_prefix}-ilb-ig"
  zone  = var.backend_zone
  named_port { name = "tcp"; port = 80 }
  named_port { name = "udp"; port = 80 }
  description = "Placeholder unmanaged IG for ILB (empty by default)."
}

resource "google_compute_health_check" "internal_tcp" {
  name               = "${var.name_prefix}-ilb-hc-tcp"
  timeout_sec        = 5
  check_interval_sec = 5

  tcp_health_check {
    port = 80
  }

  log_config {
    enable = true
  }

  labels = var.labels
}

resource "google_compute_region_backend_service" "internal" {
  name                  = "${var.name_prefix}-ilb-bes"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.internal_tcp.self_link]

  backend {
    group          = var.backend_instance_group_zonal == null ? google_compute_instance_group.placeholder_ig[0].self_link : var.backend_instance_group_zonal
    balancing_mode = "CONNECTION"
  }

  labels = var.labels
}

resource "google_compute_forwarding_rule" "internal_tcp" {
  for_each              = local.internal_tcp_ports
  name                  = "${var.name_prefix}-ilb-tcp-${each.value}"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.internal_ip.address
  ip_protocol           = "TCP"
  ports                 = [tostring(each.value)]
  backend_service       = google_compute_region_backend_service.internal.self_link
  network               = local.network_self_link
  subnetwork            = local.subnetwork_self_link
  labels                = var.labels
}

resource "google_compute_forwarding_rule" "internal_udp" {
  for_each              = local.internal_udp_ports
  name                  = "${var.name_prefix}-ilb-udp-${each.value}"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.internal_ip.address
  ip_protocol           = "UDP"
  ports                 = [tostring(each.value)]
  backend_service       = google_compute_region_backend_service.internal.self_link
  network               = local.network_self_link
  subnetwork            = local.subnetwork_self_link
  labels                = var.labels
}
