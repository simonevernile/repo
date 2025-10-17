variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region for the resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone for the resources"
  type        = string
  default     = "us-central1-a"
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "machine_type" {
  description = "The type of machine for the VM"
  type        = string
  default     = "n1-standard-1"
}

variable "disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "The type of disk for the VM"
  type        = string
  default     = "pd-standard"
}

variable "image" {
  description = "The image used to initialize the boot disk"
  type        = string
  default     = "debian-9-stretch-v20191210"
}

variable "network" {
  description = "The network used by the VM"
  type        = string
  default     = "default"
}

variable "location" {
  description = "The location of the KMS key ring"
  type        = string
  default     = "global"
}
