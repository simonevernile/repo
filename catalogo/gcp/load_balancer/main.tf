locals {
  enabled_lbs = {
    for idx, lb in var.load_balancers :
    idx => lb if try(lb.enabled, true)
  }

  external_lbs = {
    for idx, lb in local.enabled_lbs :
    idx => lb if lower(lb.type) == "external"
  }

  internal_lbs = {
    for idx, lb in local.enabled_lbs :
    idx => lb if lower(lb.type) == "internal"
  }
}

module "external" {
  for_each = local.external_lbs

  source = "/opt/poc1a/agent/tmp/repo/catalogo/gcp/load_balancer_external"

  project_id  = var.project_id
  region      = each.value.region
  name_prefix = each.value.name_prefix
  labels      = try(each.value.labels, {})

  tcp_ports = try(each.value.tcp_ports, [])
  udp_ports = try(each.value.udp_ports, [])
  target_pool_instances = try(each.value.target_pool_instances, [])
}

module "internal" {
  for_each = local.internal_lbs

  source = "/opt/poc1a/agent/tmp/repo/catalogo/gcp/load_balancer_internal"

  project_id  = var.project_id
  region      = each.value.region
  name_prefix = each.value.name_prefix
  labels      = try(each.value.labels, {})

  tcp_ports = try(each.value.tcp_ports, [])
  udp_ports = try(each.value.udp_ports, [])

  network                      = try(each.value.network, null)
  subnetwork                   = try(each.value.subnetwork, null)
  address                      = try(each.value.address, null)
  backend_instance_group_zonal = try(each.value.backend_ig, null)
}