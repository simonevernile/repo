locals {
  tcp_ports = toset(var.tcp_ports)
  udp_ports = toset(var.udp_ports)
}
