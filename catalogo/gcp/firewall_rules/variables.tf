variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "network" {
  description = "Name or self-link of the VPC the rules apply to."
  type        = string
}

variable "enable_logging" {
  description = "Enable VPC firewall rule logging on every rule."
  type        = bool
  default     = false
}

variable "rules" {
  description = <<-EOT
  List of firewall rules. Each rule maps directly to google_compute_firewall.
  Example:

    rules = [
      {
        name          = "allow-internal-tcp"
        direction     = "INGRESS"
        action        = "ALLOW"
        priority      = 1000
        source_ranges = ["10.0.0.0/8"]
        target_tags   = ["app"]
        rules = [
          { protocol = "tcp", ports = ["80","443"] },
          { protocol = "icmp" },
        ]
      },
      {
        name               = "deny-egress-to-bad-cidrs"
        direction          = "EGRESS"
        action             = "DENY"
        priority           = 100
        destination_ranges = ["198.51.100.0/24"]
        rules              = [{ protocol = "all" }]
      },
    ]
  EOT
  type = list(object({
    name                    = string
    description             = optional(string, "Managed by Terraform")
    direction               = optional(string, "INGRESS")
    action                  = optional(string, "ALLOW")
    priority                = optional(number, 1000)
    disabled                = optional(bool, false)
    source_ranges           = optional(list(string))
    destination_ranges      = optional(list(string))
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string), [])
    target_tags             = optional(list(string), [])
    target_service_accounts = optional(list(string), [])
    rules = list(object({
      protocol = string
      ports    = optional(list(string), [])
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.rules : contains(["ALLOW", "DENY"], upper(r.action))
    ])
    error_message = "rules[*].action must be ALLOW or DENY."
  }

  validation {
    condition = alltrue([
      for r in var.rules : contains(["INGRESS", "EGRESS"], upper(r.direction))
    ])
    error_message = "rules[*].direction must be INGRESS or EGRESS."
  }

  validation {
    condition     = length(var.rules) == length(distinct([for r in var.rules : r.name]))
    error_message = "rules[*].name must be unique."
  }
}
