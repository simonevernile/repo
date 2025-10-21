locals {
  net_self_link = can(regex("^https?://", var.network)) ? var.network : format("projects/%s/global/networks/%s", var.project_id, var.network)
  sub_self_link = var.subnetwork == null ? null : (can(regex("^https?://", var.subnetwork)) ? var.subnetwork : format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, var.subnetwork))

  tcp_ports = toset(var.tcp_ports)
  udp_ports = toset(var.udp_ports)
}
