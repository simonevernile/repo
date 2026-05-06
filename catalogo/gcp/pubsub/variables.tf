variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "topic" {
  description = "Pub/Sub topic name."
  type        = string
}

variable "labels" {
  description = "Labels applied to the topic."
  type        = map(string)
  default     = {}
}

variable "message_retention_duration" {
  description = "How long the topic retains unacked messages (e.g. 86400s)."
  type        = string
  default     = null
}

variable "kms_key_name" {
  description = "Optional Cloud KMS key for CMEK encryption."
  type        = string
  default     = null
}

variable "allowed_persistence_regions" {
  description = "Regions where messages may be persisted. Empty list = no restriction."
  type        = list(string)
  default     = []
}

variable "schema" {
  description = "Optional schema_settings for the topic."
  type = object({
    schema   = string
    encoding = optional(string, "JSON")
  })
  default = null
}

variable "publishers" {
  description = "List of IAM members granted roles/pubsub.publisher on the topic."
  type        = list(string)
  default     = []
}

variable "subscriptions" {
  description = "Subscriptions to create on the topic."
  type = list(object({
    name                       = string
    ack_deadline_seconds       = optional(number, 10)
    message_retention_duration = optional(string, "604800s")
    retain_acked_messages      = optional(bool, false)
    enable_message_ordering    = optional(bool, false)
    filter                     = optional(string)
    labels                     = optional(map(string), {})
    expiration_ttl             = optional(string, "")
    retry_minimum_backoff      = optional(string, "10s")
    retry_maximum_backoff      = optional(string, "600s")
    dead_letter_topic          = optional(string)
    max_delivery_attempts      = optional(number, 5)
    push_endpoint              = optional(string)
    push_oidc_service_account  = optional(string)
    push_oidc_audience         = optional(string)
  }))
  default = []
}
