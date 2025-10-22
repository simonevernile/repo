variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "tcp_ports" {
  description = "List of TCP ports for the forwarding rule"
  type        = list(string)
  default     = []
}

variable "udp_ports" {
  description = "List of UDP ports for the forwarding rule"
  type        = list(string)
  default     = []
}

variable "network" {
  description = "VPC network name"
  type        = string
}

variable "subnetwork" {
  description = "VPC subnetwork name"
  type        = string
}

variable "address" {
  description = "Internal IP address for the forwarding rule"
  type        = string
  default     = null
}

variable "backend_instance_group_zonal" {
  description = "Self-link of the backend zonal instance group"
  type        = string
}
