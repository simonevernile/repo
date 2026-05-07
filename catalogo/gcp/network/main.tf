resource "google_compute_network" "vpc" {
  name                            = var.name
  project                         = var.project_id
  description                     = var.description
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  mtu                             = var.mtu
  delete_default_routes_on_create = var.delete_default_internet_route
  enable_ula_internal_ipv6        = var.enable_ula_internal_ipv6
}

resource "google_compute_route" "egress_internet" {
  count = var.create_egress_internet_route ? 1 : 0

  name             = "${var.name}-egress-internet"
  project          = var.project_id
  network          = google_compute_network.vpc.self_link
  description      = "Default route to the public internet"
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  tags             = var.egress_internet_route_tags
}

resource "google_compute_global_address" "private_service_access" {
  count = var.enable_private_service_access ? 1 : 0

  name          = "${var.name}-psa"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_service_access_prefix_length
  network       = google_compute_network.vpc.self_link
  description   = "Reserved range for Private Service Access (Cloud SQL, Memorystore, ...)"
}

resource "google_service_networking_connection" "private_service_access" {
  count = var.enable_private_service_access ? 1 : 0

  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_access[0].name]
}
