variable "region" {
  description = "The region for the load balancer"
  type        = string
}

variable "network" {
  description = "The network for the load balancer"
  type        = string
  default     = "default"
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
