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

  oslogin_metadata = var.enable_oslogin ? { enable-oslogin = "TRUE" } : {}
  merged_metadata  = merge(var.metadata, local.oslogin_metadata)

  base_labels = {
    managed-by = "terraform"
  }
  effective_labels = merge(local.base_labels, var.labels)
}

resource "google_compute_disk" "boot" {
  name    = var.boot_disk.name
  project = var.project_id
  size    = var.boot_disk.size
  type    = var.boot_disk.type
  zone    = var.zone
  image   = var.boot_disk_image
  labels  = local.effective_labels

  dynamic "disk_encryption_key" {
    for_each = var.kms_key_self_link == null ? [] : [var.kms_key_self_link]
    content {
      kms_key_self_link = disk_encryption_key.value
    }
  }
}

resource "google_compute_disk" "additional" {
  for_each = local.additional_disks_map

  name    = each.value.name
  project = var.project_id
  size    = each.value.size
  type    = each.value.type
  zone    = var.zone
  labels  = local.effective_labels

  dynamic "disk_encryption_key" {
    for_each = var.kms_key_self_link == null ? [] : [var.kms_key_self_link]
    content {
      kms_key_self_link = disk_encryption_key.value
    }
  }
}

resource "google_compute_instance" "my_vm" {
  name             = var.vm_name
  project          = var.project_id
  machine_type     = var.machine_type
  zone             = var.zone
  min_cpu_platform = var.min_cpu_platform
  can_ip_forward   = var.can_ip_forward

  boot_disk {
    source = google_compute_disk.boot.self_link
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {
        nat_ip = var.public_ip_address
      }
    }
  }

  tags                    = distinct(concat(var.tags, var.firewall_tags))
  labels                  = local.effective_labels
  metadata                = local.merged_metadata
  metadata_startup_script = var.metadata_startup_script

  dynamic "service_account" {
    for_each = var.service_account == null ? [] : [var.service_account]
    content {
      email  = service_account.value.email
      scopes = service_account.value.scopes
    }
  }

  shielded_instance_config {
    enable_secure_boot          = var.shielded_vm.secure_boot
    enable_vtpm                 = var.shielded_vm.vtpm
    enable_integrity_monitoring = var.shielded_vm.integrity_monitoring
  }

  dynamic "confidential_instance_config" {
    for_each = var.enable_confidential_compute ? [1] : []
    content {
      enable_confidential_compute = true
    }
  }

  scheduling {
    preemptible                 = var.spot ? false : var.preemptible
    automatic_restart           = (var.preemptible || var.spot) ? false : true
    provisioning_model          = var.spot ? "SPOT" : "STANDARD"
    instance_termination_action = var.spot ? "STOP" : null
  }

  deletion_protection = var.deletion_protection

  dynamic "attached_disk" {
    for_each = local.additional_disks_map
    content {
      source      = google_compute_disk.additional[attached_disk.key].self_link
      device_name = attached_disk.value.device_name
      mode        = attached_disk.value.mode
    }
  }
}
