terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "create_external" {
  type    = bool
  default = true
}

variable "create_internal" {
  type    = bool
  default = true
}

# 1) Wrapper with multiple LBs
module "load_balancers" {
  source     = "../catalogo/gcp/load_balancer"
  project_id = var.project_id

  load_balancers = [
    {
      name_prefix = "app-ext"
      type        = "external"
      region      = var.region
      tcp_ports   = [80, 443]
      udp_ports   = [53]
      labels      = { app = "frontend" }
    },
    {
      name_prefix  = "app-int"
      type         = "internal"
      region       = var.region
      network      = "default"
      subnetwork   = "default"
      tcp_ports    = [8080, 8443]
      backend_zone = "europe-west1-b"
      labels       = { app = "backend" }
    },
    {
      name_prefix = "disabled-int"
      type        = "internal"
      region      = var.region
      network     = "default"
      subnetwork  = "default"
      enabled     = false
    }
  ]
}

# 2) Single modules with count toggles
module "lb_ext" {
  source = "../catalogo/gcp/load_balancer_external"
  count  = var.create_external ? 1 : 0

  project_id  = var.project_id
  region      = var.region
  name_prefix = "standalone-ext"

  tcp_ports = [80, 443]
}

module "lb_int" {
  source = "../catalogo/gcp/load_balancer_internal"
  count  = var.create_internal ? 1 : 0

  project_id  = var.project_id
  region      = var.region
  name_prefix = "standalone-int"

  network      = "default"
  subnetwork   = "default"
  tcp_ports    = [8080]
  backend_zone = "europe-west1-b"
}
