// --------- General ---------
variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for regional resources (LBs, addresses, backend services)."
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources."
  type        = map(string)
  default     = {}
}

// --------- Networking (ILB) ---------
variable "network" {
  description = "VPC network self_link or name for Internal LB."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork self_link or name for Internal LB."
  type        = string
  default     = null
}

// Optionally reserve a specific ILB address (e.g., 10.0.10.10). If null, Google will auto-assign.
variable "ilb_address" {
  description = "Static internal IP for the Internal TCP/UDP LB (optional)."
  type        = string
  default     = null
}

// --------- Backends ---------
// External NLB uses a Target Pool (legacy). We create one by default; attach instances via 'external_target_pool_instances' if desired.
variable "external_target_pool_instances" {
  description = "List of self_links of instances to add to the external Target Pool."
  type        = list(string)
  default     = []
}

// Internal ILB uses a Regional Backend Service with an (un)managed instance group as backend.
variable "ilb_backend_instance_group_zonal" {
  description = "Self_link of a ZONAL Instance Group to be used as backend for ILB. If null, a placeholder unmanaged IG will be created (empty)."
  type        = string
  default     = null
}

variable "ilb_backend_zone" {
  description = "Zone for the placeholder Instance Group if 'ilb_backend_instance_group_zonal' is null."
  type        = string
  default     = null
}

// --------- Ports (variabilized) ---------
variable "external_tcp_ports" {
  description = "List of TCP ports for the External TCP Network Load Balancer."
  type        = list(number)
  default     = [80, 443]
}

variable "external_udp_ports" {
  description = "List of UDP ports for the External UDP Network Load Balancer."
  type        = list(number)
  default     = []
}

variable "internal_tcp_ports" {
  description = "List of TCP ports for the Internal TCP Load Balancer."
  type        = list(number)
  default     = [80]
}

variable "internal_udp_ports" {
  description = "List of UDP ports for the Internal UDP Load Balancer."
  type        = list(number)
  default     = []
}

// --------- Names ---------
variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "lb"
}
