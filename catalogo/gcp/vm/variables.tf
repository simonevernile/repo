variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-central2"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-central2-a"
}

variable "vm_name" {
  description = "Compute Engine instance name"
  type        = string
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "e2-standard-2"
}

variable "disk_name" {
  description = "Boot disk name"
  type        = string
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"
}

variable "image" {
  description = "Image used to initialize the boot disk"
  type        = string
}

variable "network" {
  description = "VPC network name"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "VPC subnetwork name"
  type        = string
}

variable "tags" {
  description = "A list of network tags to apply to the instance."
  type        = list(string)
  default     = []
}