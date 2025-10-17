provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_kms_key_ring" "key_ring" {
  name     = "my-key-ring"
  location = var.location
}

resource "google_kms_crypto_key" "crypto_key" {
  name     = "my-key"
  key_ring = google_kms_key_ring.key_ring.id
  purpose  = "ENCRYPT_DECRYPT"
}

resource "google_compute_disk" "my_disk" {
  name  = "my-disk"
  size  = var.disk_size
  type  = var.disk_type
  zone  = var.zone

  disk_encryption_key {
    kms_key_self_link = google_kms_crypto_key.crypto_key.id
  }
}

resource "google_compute_instance" "my_vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = var.disk_type
    }

    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.crypto_key.id
    }
  }

  network_interface {
    network = var.network
    access_config {
      // Public IP address
    }
  }

  tags = ["web", "load-balancer"]

  metadata = {
    startup-script = "#!/bin/bash\nsudo apt-get update && sudo apt-get install -y apache2"
  }
}