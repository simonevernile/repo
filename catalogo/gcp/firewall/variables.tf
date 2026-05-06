variable "project_id" {
  description = "Optional project ID. When null the provider's default project is used."
  type        = string
  default     = null
}

variable "network" {
  description = "Name or self-link of the network where firewall rules apply"
  type        = string
}

variable "name_prefix" {
  description = "Prefix prepended to every firewall rule name created by the module. Avoids name collisions when more than one instance of the module exists in the same project."
  type        = string
  default     = "fw"
}

variable "target_tags" {
  description = "List of tags applied to instances that will receive the rules"
  type        = list(string)
}

variable "local_range" {
  description = "List of CIDR blocks allowed to SSH into the targets"
  type        = list(string)
}

variable "ssh_tags" {
  description = "Additional target tags for instances receiving the SSH rule"
  type        = list(string)
  default     = []
}

variable "allow_iap_ssh" {
  description = "When true, automatically adds Google's IAP source range (35.235.240.0/20) to the allowed SSH sources."
  type        = bool
  default     = false
}

variable "allow_http" {
  description = "Enables ingress for HTTP traffic on port 80"
  type        = bool
  default     = false
}

variable "allow_https" {
  description = "Enables ingress for HTTPS traffic on port 443"
  type        = bool
  default     = false
}

variable "allow_health_checks" {
  description = "Allow Google health-check source ranges (LB probes) to hit the targets."
  type        = bool
  default     = false
}

variable "priority" {
  description = "Default priority for firewall rules created by the module (lower number = higher priority)."
  type        = number
  default     = 1000
}

variable "enable_logging" {
  description = "Enable VPC firewall rule logging on every rule the module creates."
  type        = bool
  default     = false
}

variable "disabled" {
  description = "Create the rules in disabled state (useful for staged rollouts)."
  type        = bool
  default     = false
}

variable "custom_rules" {
  description = <<-EOT
  List of additional firewall rules to manage in a single resource block. Each rule follows
  google_compute_firewall semantics. Example:

    custom_rules = [
      {
        name          = "allow-icmp"
        direction     = "INGRESS"
        priority      = 1000
        action        = "ALLOW"
        source_ranges = ["10.0.0.0/8"]
        target_tags   = ["icmp"]
        rules = [
          { protocol = "icmp", ports = [] }
        ]
      }
    ]
  EOT
  type = list(object({
    name          = string
    description   = optional(string, "Managed by Terraform")
    direction     = optional(string, "INGRESS")
    priority      = optional(number, 1000)
    action        = optional(string, "ALLOW") # ALLOW | DENY
    disabled      = optional(bool, false)
    source_ranges = optional(list(string))
    source_tags   = optional(list(string))
    target_tags   = optional(list(string), [])
    rules = list(object({
      protocol = string
      ports    = optional(list(string), [])
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.custom_rules : contains(["ALLOW", "DENY"], upper(r.action))
    ])
    error_message = "custom_rules[*].action must be either ALLOW or DENY."
  }

  validation {
    condition = alltrue([
      for r in var.custom_rules : contains(["INGRESS", "EGRESS"], upper(r.direction))
    ])
    error_message = "custom_rules[*].direction must be either INGRESS or EGRESS."
  }
}
