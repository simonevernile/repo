variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "account_id" {
  description = "Service account ID (the local part of the email)."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.account_id))
    error_message = "account_id must be 6-30 chars, lowercase letters/digits/hyphens, starting with a letter."
  }
}

variable "display_name" {
  description = "Friendly display name."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the service account."
  type        = string
  default     = null
}

variable "disabled" {
  description = "When true the service account is created in disabled state."
  type        = bool
  default     = false
}

variable "project_roles" {
  description = "List of project-level IAM roles granted to the service account."
  type        = list(string)
  default     = []
}

variable "impersonators" {
  description = "Members allowed to impersonate this service account (roles/iam.serviceAccountTokenCreator)."
  type        = list(string)
  default     = []
}

variable "create_key" {
  description = "When true a JSON key is generated. Avoid in production - prefer Workload Identity Federation."
  type        = bool
  default     = false
}
