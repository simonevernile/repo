locals {
  rules_map = { for r in var.rules : r.name => r }

  log_config_blocks = var.enable_logging ? [{ metadata = "INCLUDE_ALL_METADATA" }] : []
}

resource "google_compute_firewall" "rules" {
  for_each = local.rules_map

  name        = each.value.name
  project     = var.project_id
  network     = var.network
  description = each.value.description

  direction          = upper(each.value.direction)
  priority           = each.value.priority
  disabled           = each.value.disabled
  destination_ranges = upper(each.value.direction) == "EGRESS" ? each.value.destination_ranges : null
  source_ranges      = upper(each.value.direction) == "INGRESS" ? each.value.source_ranges : null
  source_tags        = upper(each.value.direction) == "INGRESS" ? each.value.source_tags : null
  source_service_accounts = (
    upper(each.value.direction) == "INGRESS" && length(each.value.source_service_accounts) > 0
    ? each.value.source_service_accounts
    : null
  )
  target_tags             = each.value.target_tags
  target_service_accounts = length(each.value.target_service_accounts) > 0 ? each.value.target_service_accounts : null

  dynamic "allow" {
    for_each = upper(each.value.action) == "ALLOW" ? each.value.rules : []
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = upper(each.value.action) == "DENY" ? each.value.rules : []
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
