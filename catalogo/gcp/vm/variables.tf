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

variable "min_cpu_platform" {
  description = "Optional minimum CPU platform for the instance (e.g. 'Intel Cascade Lake'). Null means GCP default."
  type        = string
  default     = null
}

variable "can_ip_forward" {
  description = "Whether the instance can send/receive packets with non-matching source/destination IPs."
  type        = bool
  default     = false
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

variable "assign_public_ip" {
  description = "When true, an ephemeral (or supplied) external IP is attached to the instance."
  type        = bool
  default     = true
}

variable "public_ip_address" {
  description = "Optional external static IP to attach. Only used when assign_public_ip is true."
  type        = string
  default     = null
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

variable "labels" {
  description = "Labels applied to the instance and its disks."
  type        = map(string)
  default     = {}
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

variable "service_account" {
  description = <<-EOT
  Service account configuration attached to the VM. Set to null to use the Compute Engine default
  service account behavior (no explicit binding). Attributes:
    - email: service account email.
    - scopes: OAuth scopes (defaults to cloud-platform when omitted).
  EOT
  type = object({
    email  = string
    scopes = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
  })
  default = null
}

variable "shielded_vm" {
  description = "Shielded VM configuration. Defaults provide a secure baseline."
  type = object({
    secure_boot          = optional(bool, true)
    vtpm                 = optional(bool, true)
    integrity_monitoring = optional(bool, true)
  })
  default = {}
}

variable "enable_confidential_compute" {
  description = "Enable AMD SEV confidential computing. Requires a supported machine type (e.g. n2d-standard-2)."
  type        = bool
  default     = false
}

variable "enable_oslogin" {
  description = "Enable OS Login on the instance, granting access via IAM instead of SSH keys in metadata."
  type        = bool
  default     = false
}

variable "preemptible" {
  description = "Create the instance as preemptible (24h max). Ignored when spot is true."
  type        = bool
  default     = false
}

variable "spot" {
  description = "Create the instance using the Spot provisioning model. Takes precedence over preemptible."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Prevent Terraform from deleting the instance through GCP."
  type        = bool
  default     = false
}

variable "kms_key_self_link" {
  description = "Optional Cloud KMS key self-link used to encrypt boot and additional disks (CMEK)."
  type        = string
  default     = null
}
