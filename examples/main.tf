terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 7.0"
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

  common_labels = {
    environment = "demo"
    owner       = "infra-team"
  }
}

module "vm_sa" {
  source     = "../catalogo/gcp/service_account"
  project_id = var.project_id

  account_id   = "infra-vm-sa"
  display_name = "Service account for infra-vm-01"
  description  = "Runtime identity used by the example VM"

  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

module "vm" {
  source     = "../catalogo/gcp/vm"
  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  vm_name = "infra-vm-01"

  network    = var.network
  subnetwork = var.subnetwork

  boot_disk = {
    name = "infra-vm-01-boot"
    size = 20
    type = "pd-balanced"
  }

  # Lo startup.sh usa dnf e il gruppo wheel: serve un'immagine RHEL-based.
  boot_disk_image = "projects/rocky-linux-cloud/global/images/family/rocky-linux-9"

  labels = local.common_labels
  tags   = [local.service_tag, local.ssh_tag]
  metadata = {
    "block-project-ssh-keys" = "TRUE"
  }

  service_account = {
    email = module.vm_sa.email
  }

  shielded_vm = {
    secure_boot          = true
    vtpm                 = true
    integrity_monitoring = true
  }

  metadata_startup_script = file("${path.module}/startup.sh")
}

module "firewall" {
  source     = "../catalogo/gcp/firewall"
  project_id = var.project_id

  name_prefix         = "infra"
  network             = var.network
  target_tags         = [local.service_tag]
  local_range         = [var.ssh_source_cidr]
  ssh_tags            = [local.ssh_tag]
  allow_http          = true
  allow_iap_ssh       = true
  allow_health_checks = true
  enable_logging      = true
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
      labels      = local.common_labels

      target_pool_instances = [module.vm.instance_self_link]
    }
  ]
}

module "artifacts_bucket" {
  source     = "../catalogo/gcp/gcs_bucket"
  project_id = var.project_id

  name                        = "${var.project_id}-infra-artifacts"
  location                    = upper(substr(var.region, 0, 2)) == "EU" ? "EU" : "US"
  versioning                  = true
  uniform_bucket_level_access = true
  labels                      = local.common_labels

  lifecycle_rules = [
    {
      action    = { type = "SetStorageClass", storage_class = "NEARLINE" }
      condition = { age = "30" }
    },
    {
      action    = { type = "Delete" }
      condition = { age = "365" }
    },
  ]
}

output "ssh_user" {
  description = "Service user provisioned by examples/startup.sh."
  value       = local.ssh_user
}

output "vm_service_account" {
  description = "Service account attached to the VM."
  value       = module.vm_sa.email
}

output "artifacts_bucket_url" {
  description = "GCS URL of the artifacts bucket."
  value       = module.artifacts_bucket.url
}
