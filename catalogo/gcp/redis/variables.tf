variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Nome dell'istanza Memorystore Redis"
  type        = string
}

variable "region" {
  description = "Regione in cui creare l'istanza"
  type        = string
  default     = "europe-west1"
}

variable "tier" {
  description = "Tier di disponibilità (BASIC o STANDARD_HA)"
  type        = string
  default     = "BASIC"
}

variable "memory_size_gb" {
  description = "Dimensione della memoria in GB"
  type        = number
  default     = 1
}

variable "auth_enabled" {
  description = "Abilita l'autenticazione su Redis"
  type        = bool
  default     = false
}
