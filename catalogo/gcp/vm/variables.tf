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

variable "boot_disk" {
  description = <<-EOT
  Configuration for the instance boot disk. The following attributes are supported:
    - name (required): disk name.
    - size (optional): disk size in GB (defaults to 10 when omitted).
    - type (optional): disk type such as pd-standard, pd-balanced, or pd-ssd (defaults to pd-standard).
  EOT
  type = object({
    name = string
    size = optional(number, 10)
    type = optional(string, "pd-standard")
  })
}

variable "boot_disk_image" {
  description = "Image used to initialize the boot disk. Accepts full self link or family reference."
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

variable "firewall_tags" {
  description = "Additional network tags that correspond to existing firewall rules."
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = "Metadata key/value pairs attached to the instance."
  type        = map(string)
  default     = {}
}

variable "metadata_startup_script" {
  description = "Startup script executed on the instance when it boots."
  type        = string
  default     = null
}

variable "additional_disks" {
  description = <<-EOT
  List of additional persistent disks to create and attach to the instance. Each entry supports the
  following attributes:
    - name (required): disk name.
    - size: size in GB (defaults to var.boot_disk.size when omitted).
    - type: disk type (defaults to var.boot_disk.type when omitted).
    - mode: attachment mode, READ_WRITE or READ_ONLY (defaults to READ_WRITE).
    - device_name: device name exposed to the guest (defaults to the disk name).
  EOT
  type = list(
    object({
      name        = string
      size        = optional(number)
      type        = optional(string)
      mode        = optional(string)
      device_name = optional(string)
    })
  )
  default = []

  validation {
    condition = alltrue([
      for disk in var.additional_disks : disk.name != ""
    ])
    error_message = "Each additional disk must include a non-empty \"name\" key."
  }

  validation {
    condition = length(var.additional_disks) == length(distinct([
      for disk in var.additional_disks : disk.name
    ]))
    error_message = "Additional disk names must be unique."
  }
}
