resource "google_compute_disk" "my_disk" {
  name = var.disk_name
  size = var.disk_size
  type = var.disk_type
  zone = var.zone
}

resource "google_compute_instance" "my_vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    source = google_compute_disk.my_disk.self_link
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {
      // Public IP address
    }
  }

  tags = var.tags

  metadata = {}
}