variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "load_balancers" {
  description = "List of load balancers to create (internal or external)."
  type = list(object({
    name_prefix = string
    type        = string # "external" | "internal"
    region      = string
    # Network only for internal
    network    = optional(string)
    subnetwork = optional(string)
    address    = optional(string)

    # Ports
    tcp_ports = optional(list(number))
    udp_ports = optional(list(number))

    # External target pool instances
    target_pool_instances = optional(list(string))

    # Internal backends
    backend_zone = optional(string)
    backend_ig   = optional(string)

    labels  = optional(map(string))
    enabled = optional(bool, true)
  }))
  default = []
}
