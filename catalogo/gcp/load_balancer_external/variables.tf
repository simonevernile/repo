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

// Backends (Target Pool instances)
variable "target_pool_instances" {
  description = "List of instance self_links to add to the external Target Pool."
  type        = list(string)
  default     = []
}

// Ports (variabilized)
variable "tcp_ports" {
  description = "List of TCP ports to expose via External Network Load Balancer."
  type        = list(number)
  default     = [80, 443]
}

variable "udp_ports" {
  description = "List of UDP ports to expose via External Network Load Balancer."
  type        = list(number)
  default     = []
}
