variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "service_name" {
  description = "Cloud Run service name."
  type        = string
}

variable "location" {
  description = "Region where the service runs."
  type        = string
  default     = "europe-west1"
}

variable "image" {
  description = "Container image to deploy (e.g. europe-docker.pkg.dev/PROJECT/REPO/IMAGE:TAG)."
  type        = string
}

variable "labels" {
  description = "Labels applied to the Cloud Run service."
  type        = map(string)
  default     = {}
}

variable "service_account" {
  description = "Optional service account email used by the running revision. Falls back to the Compute default when null."
  type        = string
  default     = null
}

variable "ingress" {
  description = "Ingress restriction (INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER)."
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

variable "execution_environment" {
  description = "Execution environment (EXECUTION_ENVIRONMENT_GEN1 or EXECUTION_ENVIRONMENT_GEN2)."
  type        = string
  default     = "EXECUTION_ENVIRONMENT_GEN2"
}

variable "request_timeout" {
  description = "Maximum request duration before the request is terminated (e.g. 60s)."
  type        = string
  default     = "60s"
}

variable "max_concurrency" {
  description = "Maximum number of concurrent requests handled by a single instance."
  type        = number
  default     = 80
}

variable "scaling" {
  description = "Auto-scaling bounds for the revision."
  type = object({
    min_instances = optional(number, 0)
    max_instances = optional(number, 100)
  })
  default = {}
}

variable "resource_limits" {
  description = "Resource limits for the container, e.g. { cpu = '1', memory = '512Mi' }."
  type        = map(string)
  default = {
    cpu    = "1"
    memory = "512Mi"
  }
}

variable "cpu_idle" {
  description = "Whether CPU is throttled when not in use (CPU always-allocated when false)."
  type        = bool
  default     = true
}

variable "startup_cpu_boost" {
  description = "Allocate extra CPU during instance startup."
  type        = bool
  default     = false
}

variable "vpc_access" {
  description = "Optional Serverless VPC connector configuration."
  type = object({
    connector = string
    egress    = optional(string, "PRIVATE_RANGES_ONLY")
  })
  default = null
}

variable "env_vars" {
  description = "Map of environment variable name → value passed to the container."
  type        = map(string)
  default     = {}
}

variable "secret_env_vars" {
  description = "List of environment variables fetched from Secret Manager."
  type = list(object({
    name    = string
    secret  = string
    version = optional(string, "latest")
  }))
  default = []
}

variable "startup_probe" {
  description = "Optional TCP startup probe configuration."
  type = object({
    port                  = number
    initial_delay_seconds = optional(number, 0)
    period_seconds        = optional(number, 10)
    timeout_seconds       = optional(number, 1)
    failure_threshold     = optional(number, 3)
  })
  default = null
}

variable "liveness_probe" {
  description = "Optional HTTP liveness probe configuration."
  type = object({
    port                  = number
    path                  = optional(string, "/")
    initial_delay_seconds = optional(number, 0)
    period_seconds        = optional(number, 10)
    timeout_seconds       = optional(number, 1)
    failure_threshold     = optional(number, 3)
  })
  default = null
}

variable "allow_unauthenticated" {
  description = "When true, grants roles/run.invoker to allUsers (public service)."
  type        = bool
  default     = false
}

variable "invoker_members" {
  description = "List of IAM members granted roles/run.invoker on the service (e.g. 'serviceAccount:foo@bar.iam.gserviceaccount.com')."
  type        = list(string)
  default     = []
}

variable "deletion_protection" {
  description = "Enable Cloud Run deletion protection."
  type        = bool
  default     = false
}
