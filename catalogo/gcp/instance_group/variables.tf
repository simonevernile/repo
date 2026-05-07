variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name" {
  description = "Instance group name. The group is unmanaged and zonal — typical use is as the backend of an internal/network load balancer."
  type        = string
}

variable "zone" {
  description = "Zone where the instance group lives. All member instances must run in this zone."
  type        = string
}

variable "description" {
  description = "Free-form description."
  type        = string
  default     = "Managed by Terraform"
}

variable "network" {
  description = "Optional self-link of the VPC the group is attached to. When null GCP infers it from the member instances."
  type        = string
  default     = null
}

variable "instances" {
  description = "List of instance self-links to add to the group. All must be in the same zone as the group."
  type        = list(string)
  default     = []
}

variable "named_ports" {
  description = "Named ports exposed by the group, e.g. [{ name = \"http\", port = 80 }, { name = \"https\", port = 443 }]."
  type = list(object({
    name = string
    port = number
  }))
  default = []
}
