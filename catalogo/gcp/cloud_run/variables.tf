variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "service_name" {
  description = "Nome del servizio Cloud Run"
  type        = string
}

variable "location" {
  description = "Regione in cui creare il servizio"
  type        = string
  default     = "europe-west1"
}

variable "image" {
  description = "Container image da deployare (es. gcr.io/project/image:tag)"
  type        = string
}

variable "env_vars" {
  description = "Mappa di variabili d'ambiente da passare al container"
  type        = map(string)
  default     = {}
}

variable "allow_unauthenticated" {
  description = "Quando true consente l'invocazione pubblica del servizio"
  type        = bool
  default     = true
}
