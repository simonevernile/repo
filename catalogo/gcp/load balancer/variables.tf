variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for regional load balancer resources."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used when naming resources for the load balancers."
  type        = string
}

variable "labels" {
  description = "Labels to apply to created resources."
  type        = map(string)
  default     = {}
}

variable "network" {
  description = "VPC network self_link or name for the internal load balancer."
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork self_link or name for the internal load balancer."
  type        = string
}

variable "internal_address" {
  description = "Optional static internal IP address for the internal load balancer."
  type        = string
  default     = null
}

variable "backend_instance_group_zonal" {
  description = "Self_link of an existing zonal instance group to use as backend for the internal load balancer."
  type        = string
  default     = null
}

variable "backend_zone" {
  description = "Zone to create a placeholder instance group when no backend_instance_group_zonal is provided."
  type        = string
  default     = null
}

variable "target_pool_instances" {
  description = "List of instance self_links to attach to the external target pool."
  type        = list(string)
  default     = []
}

variable "external_tcp_ports" {
  description = "TCP ports exposed by the external network load balancer."
  type        = list(number)
  default     = [80]
}

variable "external_udp_ports" {
  description = "UDP ports exposed by the external network load balancer."
  type        = list(number)
  default     = []
}

variable "internal_tcp_ports" {
  description = "TCP ports exposed by the internal load balancer."
  type        = list(number)
  default     = [80]
}

variable "internal_udp_ports" {
  description = "UDP ports exposed by the internal load balancer."
  type        = list(number)
  default     = []
}
