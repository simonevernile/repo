locals {
  net_self_link = can(regex("^https?://", var.network)) ? var.network : format("projects/%s/global/networks/%s", var.project_id, var.network)
  sub_self_link = var.subnetwork == null ? null : (can(regex("^https?://", var.subnetwork)) ? var.subnetwork : format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, var.subnetwork))

  tcp_ports_str = toset([for p in var.tcp_ports : tostring(p)])
  udp_ports_str = toset([for p in var.udp_ports : tostring(p)])
}

resource "google_compute_address" "ilb_ip" {
  name         = "${var.name_prefix}-ilb-ip"
  project      = var.project_id
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = local.sub_self_link
  address      = var.address
  purpose      = "GCE_ENDPOINT"
  labels       = var.labels
}

resource "google_compute_health_check" "ilb_hc_tcp" {
  name               = "${var.name_prefix}-ilb-hc-tcp"
  project            = var.project_id
  timeout_sec        = 5
  check_interval_sec = 5

  tcp_health_check { port = var.health_check_port }

  log_config { enable = true }
}

resource "google_compute_region_backend_service" "bes" {
  name                  = "${var.name_prefix}-ilb-bes"
  project               = var.project_id
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.ilb_hc_tcp.self_link]

  dynamic "backend" {
    for_each = var.backend_instance_group_zonal == null ? [] : [var.backend_instance_group_zonal]
    content {
      group          = backend.value
      balancing_mode = "CONNECTION"
    }
  }
}

resource "google_compute_forwarding_rule" "tcp_fr" {
  for_each              = local.tcp_ports_str
  name                  = "${var.name_prefix}-ilb-tcp-${each.value}"
  project               = var.project_id
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.ilb_ip.address
  ip_protocol           = "TCP"
  ports                 = [each.value]
  backend_service       = google_compute_region_backend_service.bes.self_link
  network               = local.net_self_link
  subnetwork            = local.sub_self_link
  labels                = var.labels
}

resource "google_compute_forwarding_rule" "udp_fr" {
  for_each              = local.udp_ports_str
  name                  = "${var.name_prefix}-ilb-udp-${each.value}"
  project               = var.project_id
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.ilb_ip.address
  ip_protocol           = "UDP"
  ports                 = [each.value]
  backend_service       = google_compute_region_backend_service.bes.self_link
  network               = local.net_self_link
  subnetwork            = local.sub_self_link
  labels                = var.labels
}
