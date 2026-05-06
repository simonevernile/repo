variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "region" {
  description = "Region where the instance is created"
  type        = string
  default     = "europe-west1"
}

variable "database_version" {
  description = "Cloud SQL database engine version"
  type        = string
  default     = "POSTGRES_16"
}

variable "tier" {
  description = "Machine type for the instance (e.g. db-f1-micro, db-custom-1-3840)"
  type        = string
  default     = "db-f1-micro"
}

variable "disk_size" {
  description = "Size of the data disk in GB"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Type of the data disk (PD_SSD or PD_HDD)"
  type        = string
  default     = "PD_SSD"
}

variable "disk_autoresize" {
  description = "Allow Cloud SQL to grow the disk automatically as it fills up."
  type        = bool
  default     = true
}

variable "availability_type" {
  description = "Availability type for the instance (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "availability_type must be ZONAL or REGIONAL."
  }
}

variable "deletion_protection" {
  description = "When true, prevents Terraform from destroying the instance"
  type        = bool
  default     = true
}

variable "postgres_password" {
  description = "Password for the postgres user; when null and generate_password is false no password is set by Terraform."
  type        = string
  default     = null
  sensitive   = true
}

variable "generate_password" {
  description = "When true, the module generates a strong postgres password using the random provider. Ignored if postgres_password is set."
  type        = bool
  default     = false
}

variable "database_name" {
  description = "Optional database to create within the instance"
  type        = string
  default     = null
}

variable "enable_public_ip" {
  description = "Enable the public IPv4 address for the instance"
  type        = bool
  default     = false
}

variable "private_network" {
  description = "Self-link of a VPC network for private IP. Requires the service-networking peering."
  type        = string
  default     = null
}

variable "ssl_mode" {
  description = "SSL enforcement: ALLOW_UNENCRYPTED_AND_ENCRYPTED, ENCRYPTED_ONLY or TRUSTED_CLIENT_CERTIFICATE_REQUIRED."
  type        = string
  default     = "ENCRYPTED_ONLY"
}

variable "authorized_networks" {
  description = "List of {name, cidr} pairs allowed when the public IP is enabled."
  type = list(object({
    name = string
    cidr = string
  }))
  default = []
}

variable "labels" {
  description = "Labels applied to the Cloud SQL instance."
  type        = map(string)
  default     = {}
}

variable "backup" {
  description = "Backup and PITR configuration."
  type = object({
    enabled                        = optional(bool, true)
    point_in_time_recovery_enabled = optional(bool, true)
    start_time                     = optional(string, "02:00")
    location                       = optional(string)
    transaction_log_retention_days = optional(number, 7)
    retained_backups               = optional(number, 7)
  })
  default = {}
}

variable "maintenance_window" {
  description = "Maintenance window for the instance. day = 1-7 (Mon-Sun), hour = 0-23."
  type = object({
    day          = optional(number, 7)
    hour         = optional(number, 3)
    update_track = optional(string, "stable")
  })
  default = {}
}

variable "insights" {
  description = "Cloud SQL Query Insights configuration."
  type = object({
    enabled                 = optional(bool, true)
    record_application_tags = optional(bool, false)
    record_client_address   = optional(bool, false)
    query_string_length     = optional(number, 1024)
  })
  default = {}
}

variable "database_flags" {
  description = "Map of database flag name → value to apply to the instance."
  type        = map(string)
  default     = {}
}

variable "additional_users" {
  description = "Extra Cloud SQL users to create alongside postgres. Pass passwords through Terraform variables marked sensitive."
  type = list(object({
    name     = string
    password = string
  }))
  default = []
}
