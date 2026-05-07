variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "network" {
  description = "Name or self-link of the VPC network the subnets belong to."
  type        = string
}

variable "region" {
  description = "Default region for subnets that don't override it."
  type        = string
  default     = "europe-west1"
}

variable "subnets" {
  description = <<-EOT
  List of subnetworks to create. Common patterns:
    - Standard private subnet:                ip_cidr_range = "10.0.0.0/24"
    - Subnet with secondary ranges (GKE):     secondary_ip_ranges = [{ range_name = "pods", ip_cidr_range = "10.10.0.0/16" }, ...]
    - Proxy-only subnet (Regional L7 LB):     purpose = "REGIONAL_MANAGED_PROXY", role = "ACTIVE"
    - PSC subnet:                             purpose = "PRIVATE_SERVICE_CONNECT"
  EOT
  type = list(object({
    name                     = string
    ip_cidr_range            = string
    region                   = optional(string)
    description              = optional(string, "Managed by Terraform")
    purpose                  = optional(string)
    role                     = optional(string)
    private_ip_google_access = optional(bool, true)
    stack_type               = optional(string, "IPV4_ONLY")
    ipv6_access_type         = optional(string)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
    flow_logs = optional(object({
      aggregation_interval = optional(string, "INTERVAL_5_SEC")
      flow_sampling        = optional(number, 0.5)
      metadata             = optional(string, "INCLUDE_ALL_METADATA")
    }))
  }))
  default = []

  validation {
    condition     = length(var.subnets) == length(distinct([for s in var.subnets : s.name]))
    error_message = "subnets[*].name must be unique."
  }
}
