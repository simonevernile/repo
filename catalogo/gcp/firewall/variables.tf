variable "network" {
  description = "The network to apply the firewall rules"
  type        = string
}

variable "target_tags" {
  description = "The tags for the firewall target"
  type        = list(string)
}

variable "local_range" {
  description = "The source IP range for local firewall rule"
  type        = string
}

variable "ssh_tags" {
  description = "The tags for SSH access"
  type        = list(string)
}

variable "allow_http" {
  description = "Flag to allow HTTP traffic (port 80)"
  type        = bool
  default     = true
}

variable "allow_https" {
  description = "Flag to allow HTTPS traffic (port 443)"
  type        = bool
  default     = true
}
