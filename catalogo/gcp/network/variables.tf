variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name" {
  description = "VPC network name."
  type        = string
}

variable "description" {
  description = "Optional description for the network."
  type        = string
  default     = "Managed by Terraform"
}

variable "auto_create_subnetworks" {
  description = "When true the VPC is created in auto-mode (a /20 subnet per region). Use false for custom-mode VPCs."
  type        = bool
  default     = false
}

variable "routing_mode" {
  description = "BGP routing mode (REGIONAL or GLOBAL)."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "routing_mode must be REGIONAL or GLOBAL."
  }
}

variable "mtu" {
  description = "MTU for the VPC (1300-8896). Default 1460."
  type        = number
  default     = 1460
}

variable "delete_default_internet_route" {
  description = "When true the implicit default route to 0.0.0.0/0 is removed at creation. Useful for fully private VPCs."
  type        = bool
  default     = false
}

variable "enable_ula_internal_ipv6" {
  description = "Enable ULA internal IPv6 ranges on the VPC."
  type        = bool
  default     = false
}

variable "create_egress_internet_route" {
  description = "Create an explicit 0.0.0.0/0 next-hop default-internet-gateway route, optionally restricted by tags."
  type        = bool
  default     = false
}

variable "egress_internet_route_tags" {
  description = "Network tags applied to the optional egress internet route. Empty list = unrestricted."
  type        = list(string)
  default     = []
}

variable "enable_private_service_access" {
  description = "Reserve a range and peer with servicenetworking.googleapis.com for Cloud SQL/Memorystore private IP."
  type        = bool
  default     = false
}

variable "private_service_access_prefix_length" {
  description = "Prefix length for the Private Service Access reserved range (default /16)."
  type        = number
  default     = 16
}
