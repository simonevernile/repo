locals {
  ext_tcp_ports = toset(var.external_tcp_ports)
  ext_udp_ports = toset(var.external_udp_ports)
  ilb_tcp_ports = toset(var.internal_tcp_ports)
  ilb_udp_ports = toset(var.internal_udp_ports)

  net_self_link = can(regex("^https?://", var.network)) ? var.network : format("projects/%s/global/networks/%s", var.project_id, var.network)
  sub_self_link = var.subnetwork == null ? null : (can(regex("^https?://", var.subnetwork)) ? var.subnetwork : format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, var.subnetwork))
}
