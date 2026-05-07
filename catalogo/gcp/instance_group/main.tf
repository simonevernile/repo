resource "google_compute_instance_group" "ig" {
  name        = var.name
  project     = var.project_id
  zone        = var.zone
  description = var.description
  network     = var.network
  instances   = var.instances

  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}
