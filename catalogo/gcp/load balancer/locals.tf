locals {
  network_self_link    = can(regex("^https?://", var.network)) ? var.network : format("projects/%s/global/networks/%s", var.project_id, var.network)
  subnetwork_self_link = can(regex("^https?://", var.subnetwork)) ? var.subnetwork : format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, var.subnetwork)

  external_tcp_ports = toset(var.external_tcp_ports)
  external_udp_ports = toset(var.external_udp_ports)
  internal_tcp_ports = toset(var.internal_tcp_ports)
  internal_udp_ports = toset(var.internal_udp_ports)
}
