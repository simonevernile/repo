locals {
  name_prefix = var.name_prefix

  iap_source_range = "35.235.240.0/20"

  ssh_sources = distinct(concat(
    var.local_range,
    var.allow_iap_ssh ? [local.iap_source_range] : []
  ))

  log_config_blocks = var.enable_logging ? [{ metadata = "INCLUDE_ALL_METADATA" }] : []
}

resource "google_compute_firewall" "allow_local_ssh" {
  name        = "${local.name_prefix}-allow-ssh"
  project     = var.project_id
  network     = var.network
  description = "Allow SSH from approved CIDRs (and IAP if enabled)"

  priority  = var.priority
  direction = "INGRESS"
  disabled  = var.disabled

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = local.ssh_sources
  target_tags   = var.ssh_tags

  dynamic "log_config" {
    for_each = local.log_config_blocks
    content {
      metadata = log_config.value.metadata
    }
  }
}

resource "google_compute_firewall" "allow_public_https" {
  count       = var.allow_https ? 1 : 0
  name        = "${local.name_prefix}-allow-https"
  project     = var.project_id
  network     = var.network
  description = "Allow public HTTPS traffic"

  priority  = var.priority
  direction = "INGRESS"
  disabled  = var.disabled

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.target_tags

  dynamic "log_config" {
    for_each = local.log_config_blocks
    content {
      metadata = log_config.value.metadata
    }
  }
}

resource "google_compute_firewall" "allow_public_http" {
  count       = var.allow_http ? 1 : 0
  name        = "${local.name_prefix}-allow-http"
  project     = var.project_id
  network     = var.network
  description = "Allow public HTTP traffic"

  priority  = var.priority
  direction = "INGRESS"
  disabled  = var.disabled

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.target_tags

  dynamic "log_config" {
    for_each = local.log_config_blocks
    content {
      metadata = log_config.value.metadata
    }
  }
}

resource "google_compute_firewall" "allow_health_checks" {
  count       = var.allow_health_checks ? 1 : 0
  name        = "${local.name_prefix}-allow-hc"
  project     = var.project_id
  network     = var.network
  description = "Allow Google health-check probes to reach LB backends"

  priority  = var.priority
  direction = "INGRESS"
  disabled  = var.disabled

  allow {
    protocol = "tcp"
  }

  # Documented Google health-check ranges.
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
    "209.85.152.0/22",
    "209.85.204.0/22",
  ]
  target_tags = var.target_tags

  dynamic "log_config" {
    for_each = local.log_config_blocks
    content {
      metadata = log_config.value.metadata
    }
  }
}

resource "google_compute_firewall" "custom" {
  for_each = { for r in var.custom_rules : r.name => r }

  name        = "${local.name_prefix}-${each.value.name}"
  project     = var.project_id
  network     = var.network
  description = each.value.description

  direction = upper(each.value.direction)
  priority  = each.value.priority
  disabled  = each.value.disabled

  source_ranges = each.value.direction == "INGRESS" ? each.value.source_ranges : null
  source_tags   = each.value.direction == "INGRESS" ? each.value.source_tags : null
  target_tags   = each.value.target_tags

  dynamic "allow" {
    for_each = each.value.action == "ALLOW" ? each.value.rules : []
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.action == "DENY" ? each.value.rules : []
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  dynamic "log_config" {
    for_each = local.log_config_blocks
    content {
      metadata = log_config.value.metadata
    }
  }
}
