terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "GCP project where resources are created"
  type        = string
}

variable "region" {
  description = "Region for regional resources like load balancers"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone hosting the Compute Engine instance"
  type        = string
  default     = "europe-west1-b"
}

variable "network" {
  description = "VPC network used by the VM"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork hosting the VM"
  type        = string
  default     = "default"
}

variable "ssh_source_cidr" {
  description = "Private CIDR (or single IP /32) allowed to SSH into the VM"
  type        = string
  default     = "192.168.10.10/32"
}

locals {
  service_tag = "http-service"
  ssh_tag     = "restricted-ssh"
  ssh_user    = "Implementazione"
}

resource "tls_private_key" "implementazione" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "vm" {
  source     = "../catalogo/gcp/vm"
  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  vm_name   = "infra-vm-01"
  disk_name = "infra-vm-01-boot"
  image     = "projects/debian-cloud/global/images/family/debian-12"

  network    = var.network
  subnetwork = var.subnetwork

  tags = [local.service_tag, local.ssh_tag]
  metadata = {
    "block-project-ssh-keys" = "TRUE"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail

    USERNAME="${local.ssh_user}"

    if ! id "$USERNAME" >/dev/null 2>&1; then
      useradd --create-home "$USERNAME"
    fi

    install -d -m 700 "/home/$USERNAME/.ssh"

    cat <<'EOF' > "/home/$USERNAME/.ssh/authorized_keys"
${tls_private_key.implementazione.public_key_openssh}
EOF

    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
    chmod 600 "/home/$USERNAME/.ssh/authorized_keys"

    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
    chmod 440 "/etc/sudoers.d/$USERNAME"
  EOT
}

module "firewall" {
  source = "../catalogo/gcp/firewall"

  network     = var.network
  target_tags = [local.service_tag]
  local_range = [var.ssh_source_cidr]
  ssh_tags    = [local.ssh_tag]
  allow_http  = true
}

module "http_lb" {
  source     = "../catalogo/gcp/load_balancer"
  project_id = var.project_id

  load_balancers = [
    {
      name_prefix = "infra"
      type        = "external"
      region      = var.region
      tcp_ports   = [80]

      target_pool_instances = [module.vm.instance_self_link]
    }
  ]
}

output "ssh_user" {
  description = "User provisioned on the VM for SSH access"
  value       = local.ssh_user
}

output "ssh_private_key_pem" {
  description = "Private key that matches the VM authorized key"
  value       = tls_private_key.implementazione.private_key_pem
  sensitive   = true
}

output "ssh_public_key" {
  description = "Public key uploaded to the VM"
  value       = tls_private_key.implementazione.public_key_openssh
}
