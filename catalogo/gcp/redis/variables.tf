variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Memorystore Redis instance name"
  type        = string
}

variable "display_name" {
  description = "Friendly display name for the instance."
  type        = string
  default     = null
}

variable "region" {
  description = "Region where the instance is created."
  type        = string
  default     = "europe-west1"
}

variable "tier" {
  description = "Service tier (BASIC or STANDARD_HA)."
  type        = string
  default     = "BASIC"

  validation {
    condition     = contains(["BASIC", "STANDARD_HA"], var.tier)
    error_message = "tier must be BASIC or STANDARD_HA."
  }
}

variable "memory_size_gb" {
  description = "Memory size in GB."
  type        = number
  default     = 1
}

variable "redis_version" {
  description = "Redis engine version (e.g. REDIS_7_2, REDIS_7_0)."
  type        = string
  default     = "REDIS_7_2"
}

variable "auth_enabled" {
  description = "Enable AUTH on the Redis instance."
  type        = bool
  default     = false
}

variable "transit_encryption_mode" {
  description = "Transit encryption mode (DISABLED or SERVER_AUTHENTICATION)."
  type        = string
  default     = "DISABLED"

  validation {
    condition     = contains(["DISABLED", "SERVER_AUTHENTICATION"], var.transit_encryption_mode)
    error_message = "transit_encryption_mode must be DISABLED or SERVER_AUTHENTICATION."
  }
}

variable "authorized_network" {
  description = "VPC network the Redis instance is attached to. Defaults to the 'default' network when null."
  type        = string
  default     = null
}

variable "connect_mode" {
  description = "Network connection mode (DIRECT_PEERING or PRIVATE_SERVICE_ACCESS)."
  type        = string
  default     = "DIRECT_PEERING"
}

variable "reserved_ip_range" {
  description = "Optional /29 CIDR block reserved for the Redis instance."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels applied to the Redis instance."
  type        = map(string)
  default     = {}
}

variable "redis_configs" {
  description = "Map of Redis runtime configuration parameters (e.g. maxmemory-policy)."
  type        = map(string)
  default     = {}
}

variable "replica_count" {
  description = "Number of read replicas (STANDARD_HA only). Set to 0 to disable replicas."
  type        = number
  default     = 0

  validation {
    condition     = var.replica_count >= 0 && var.replica_count <= 5
    error_message = "replica_count must be between 0 and 5."
  }
}

variable "read_replicas_mode" {
  description = "Read replicas mode (READ_REPLICAS_DISABLED or READ_REPLICAS_ENABLED). Only used when replica_count > 0."
  type        = string
  default     = "READ_REPLICAS_ENABLED"
}

variable "maintenance_policy" {
  description = "Optional weekly maintenance window."
  type = object({
    day     = string # MONDAY..SUNDAY
    hours   = number
    minutes = optional(number, 0)
  })
  default = null
}

variable "persistence" {
  description = "Optional RDB persistence config."
  type = object({
    mode            = optional(string, "RDB") # RDB or DISABLED
    snapshot_period = optional(string, "TWENTY_FOUR_HOURS")
  })
  default = null
}
