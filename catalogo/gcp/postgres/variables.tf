variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "region" {
  description = "Region where the instance is created"
  type        = string
  default     = "europe-west1"
}

variable "database_version" {
  description = "Cloud SQL database engine version"
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "Machine type for the instance (e.g. db-f1-micro, db-custom-1-3840)"
  type        = string
  default     = "db-f1-micro"
}

variable "disk_size" {
  description = "Size of the data disk in GB"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Type of the data disk (PD_SSD or PD_HDD)"
  type        = string
  default     = "PD_SSD"
}

variable "availability_type" {
  description = "Availability type for the instance (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"
}

variable "deletion_protection" {
  description = "When true, prevents Terraform from destroying the instance"
  type        = bool
  default     = true
}

variable "postgres_password" {
  description = "Password for the postgres user; when null no password is set by Terraform"
  type        = string
  default     = null
  sensitive   = true
}

variable "database_name" {
  description = "Optional database to create within the instance"
  type        = string
  default     = null
}

variable "enable_public_ip" {
  description = "Enable the public IPv4 address for the instance"
  type        = bool
  default     = false
}
