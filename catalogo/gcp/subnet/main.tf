resource "google_compute_subnetwork" "subnets" {
  for_each = { for s in var.subnets : s.name => s }

  name                     = each.value.name
  project                  = var.project_id
  region                   = coalesce(each.value.region, var.region)
  network                  = var.network
  ip_cidr_range            = each.value.ip_cidr_range
  description              = each.value.description
  purpose                  = each.value.purpose
  role                     = each.value.role
  private_ip_google_access = each.value.private_ip_google_access
  stack_type               = each.value.stack_type
  ipv6_access_type         = each.value.ipv6_access_type

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = each.value.flow_logs == null ? [] : [each.value.flow_logs]
    content {
      aggregation_interval = log_config.value.aggregation_interval
      flow_sampling        = log_config.value.flow_sampling
      metadata             = log_config.value.metadata
    }
  }
}
