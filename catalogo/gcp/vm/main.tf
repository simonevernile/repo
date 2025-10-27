locals {
  additional_disks = [
    for disk in var.additional_disks : {
      name        = disk.name
      size        = coalesce(disk.size, var.boot_disk.size)
      type        = coalesce(disk.type, var.boot_disk.type)
      mode        = coalesce(disk.mode, "READ_WRITE")
      device_name = coalesce(disk.device_name, disk.name)
    }
  ]

  additional_disks_map = { for disk in local.additional_disks : disk.name => disk }
}

resource "google_compute_disk" "boot" {
  name  = var.boot_disk.name
  size  = var.boot_disk.size
  type  = var.boot_disk.type
  zone  = var.zone
  image = var.boot_disk_image
}

resource "google_compute_disk" "additional" {
  for_each = local.additional_disks_map

  name = each.value.name
  size = each.value.size
  type = each.value.type
  zone = var.zone
}

resource "google_compute_instance" "my_vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    source = google_compute_disk.boot.self_link
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {}
  }

  tags                    = distinct(concat(var.tags, var.firewall_tags))
  metadata                = var.metadata
  metadata_startup_script = file("/opt/poc1a/agent/tmp/startup.sh")

  dynamic "attached_disk" {
    for_each = local.additional_disks_map
    content {
      source      = google_compute_disk.additional[attached_disk.key].self_link
      device_name = attached_disk.value.device_name
      mode        = attached_disk.value.mode
    }
  }
}
