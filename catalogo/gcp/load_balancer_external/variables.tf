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

variable "target_pool_instances" {
  description = "List of self-links for instances to add to the target pool"
  type        = list(string)
  default     = []
}