// General
variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for regional resources."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources."
  type        = map(string)
  default     = {}
}

// Networking
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

// Specific internal address (optional)
variable "address" {
  description = "Static internal IP for the ILB (optional)."
  type        = string
  default     = null
}

// Backend
variable "backend_instance_group_zonal" {
  description = "Self_link of a ZONAL Instance Group to be used as backend for ILB. If null, a placeholder unmanaged IG will be created (empty)."
  type        = string
  default     = null
}

variable "backend_zone" {
  description = "Zone for the placeholder Instance Group if 'backend_instance_group_zonal' is null."
  type        = string
  default     = null
}

// Ports
variable "tcp_ports" {
  description = "List of TCP ports to expose via Internal Load Balancer."
  type        = list(number)
  default     = [80]
}

variable "udp_ports" {
  description = "List of UDP ports to expose via Internal Load Balancer."
  type        = list(number)
  default     = []
}
