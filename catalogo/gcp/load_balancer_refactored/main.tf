// ============================
// External TCP/UDP Network LB
// ============================

resource "google_compute_address" "ext_ip" {
  name   = "${var.name_prefix}-ext-ip"
  region = var.region
  labels = var.labels
}

resource "google_compute_health_check" "ext_hc_tcp" {
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

resource "google_compute_target_pool" "ext_pool" {
  name          = "${var.name_prefix}-ext-pool"
  region        = var.region
  health_checks = [google_compute_health_check.ext_hc_tcp.self_link]
  instances     = var.external_target_pool_instances
}

// One forwarding rule per TCP port
resource "google_compute_forwarding_rule" "ext_tcp_fr" {
  for_each    = local.ext_tcp_ports
  name        = "${var.name_prefix}-ext-tcp-${each.value}"
  region      = var.region
  ip_address  = google_compute_address.ext_ip.address
  ip_protocol = "TCP"
  port_range  = tostring(each.value)
  target      = google_compute_target_pool.ext_pool.self_link
  labels      = var.labels
}

// One forwarding rule per UDP port (note: UDP health checks still use TCP/HTTP; backends are the same target pool)
resource "google_compute_forwarding_rule" "ext_udp_fr" {
  for_each    = local.ext_udp_ports
  name        = "${var.name_prefix}-ext-udp-${each.value}"
  region      = var.region
  ip_address  = google_compute_address.ext_ip.address
  ip_protocol = "UDP"
  port_range  = tostring(each.value)
  target      = google_compute_target_pool.ext_pool.self_link
  labels      = var.labels
}

// ============================
// Internal TCP/UDP Load Balancer (Regional)
// ============================

// Reserve internal IP
resource "google_compute_address" "ilb_ip" {
  name         = "${var.name_prefix}-ilb-ip"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = local.sub_self_link
  address      = var.ilb_address
  purpose      = "GCE_ENDPOINT" // Generic internal address
  labels       = var.labels
}

// Backend: pick provided IG or create placeholder empty IG
resource "google_compute_instance_group" "ilb_placeholder_ig" {
  count = var.ilb_backend_instance_group_zonal == null ? 1 : 0
  name  = "${var.name_prefix}-ilb-ig"
  zone  = var.ilb_backend_zone
  // empty instances list by default
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

// Regional Backend Service
resource "google_compute_region_backend_service" "ilb_bes" {
  name                  = "${var.name_prefix}-ilb-bes"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.ilb_hc_tcp.self_link]

  backend {
    group          = var.ilb_backend_instance_group_zonal == null ? google_compute_instance_group.ilb_placeholder_ig[0].self_link : var.ilb_backend_instance_group_zonal
    balancing_mode = "CONNECTION"
  }

  labels = var.labels
}

resource "google_compute_health_check" "ilb_hc_tcp" {
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

// Forwarding rules: one per protocol (TCP and UDP), each can serve multiple ports.
// For simplicity and explicitness, we create one rule per port too.
resource "google_compute_forwarding_rule" "ilb_tcp_fr" {
  for_each              = local.ilb_tcp_ports
  name                  = "${var.name_prefix}-ilb-tcp-${each.value}"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.ilb_ip.address
  ip_protocol           = "TCP"
  ports                 = [tostring(each.value)]
  backend_service       = google_compute_region_backend_service.ilb_bes.self_link
  network               = local.net_self_link
  subnetwork            = local.sub_self_link
  labels                = var.labels
}

resource "google_compute_forwarding_rule" "ilb_udp_fr" {
  for_each              = local.ilb_udp_ports
  name                  = "${var.name_prefix}-ilb-udp-${each.value}"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.ilb_ip.address
  ip_protocol           = "UDP"
  ports                 = [tostring(each.value)]
  backend_service       = google_compute_region_backend_service.ilb_bes.self_link
  network               = local.net_self_link
  subnetwork            = local.sub_self_link
  labels                = var.labels
}
