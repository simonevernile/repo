variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name" {
  description = "Globally unique bucket name."
  type        = string
}

variable "location" {
  description = "Bucket location (region or multi-region, e.g. EU, europe-west1)."
  type        = string
  default     = "EU"
}

variable "storage_class" {
  description = "Default storage class (STANDARD, NEARLINE, COLDLINE, ARCHIVE)."
  type        = string
  default     = "STANDARD"
}

variable "force_destroy" {
  description = "When true, terraform destroy deletes the bucket even if it contains objects."
  type        = bool
  default     = false
}

variable "uniform_bucket_level_access" {
  description = "Enforce uniform bucket-level access (no per-object ACLs)."
  type        = bool
  default     = true
}

variable "public_access_prevention" {
  description = "enforced or inherited."
  type        = string
  default     = "enforced"
}

variable "versioning" {
  description = "Enable object versioning."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels applied to the bucket."
  type        = map(string)
  default     = {}
}

variable "kms_key_name" {
  description = "Optional Cloud KMS key for default encryption (CMEK)."
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "Lifecycle rules. Each rule has an action {type, storage_class?} and a condition map."
  type = list(object({
    action    = map(string)
    condition = map(string)
  }))
  default = []
}

variable "logging" {
  description = "Optional access logging config."
  type = object({
    log_bucket        = string
    log_object_prefix = optional(string)
  })
  default = null
}

variable "retention_policy" {
  description = "Optional retention policy."
  type = object({
    retention_period = number
    is_locked        = optional(bool, false)
  })
  default = null
}

variable "cors" {
  description = "Optional list of CORS rules."
  type = list(object({
    origin          = list(string)
    method          = list(string)
    response_header = optional(list(string), [])
    max_age_seconds = optional(number, 3600)
  }))
  default = []
}

variable "iam_bindings" {
  description = "List of IAM bindings to apply to the bucket."
  type = list(object({
    role   = string
    member = string
  }))
  default = []
}
