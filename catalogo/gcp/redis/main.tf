resource "google_redis_instance" "redis" {
  name           = var.name
  project        = var.project_id
  region         = var.region
  tier           = var.tier
  memory_size_gb = var.memory_size_gb
  auth_enabled   = var.auth_enabled
}
