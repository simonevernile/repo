variable "network" {
  description = "Name or self-link of the network where firewall rules apply"
  type        = string
}

variable "target_tags" {
  description = "List of tags applied to instances that will receive the rules"
  type        = list(string)
}

variable "local_range" {
  description = "CIDR block allowed to SSH into the targets"
  type        = list(string)
}

variable "ssh_tags" {
  description = "Additional target tags for instances receiving the SSH rule"
  type        = list(string)
  default     = []
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