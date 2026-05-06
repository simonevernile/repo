resource "google_redis_instance" "redis" {
  name           = var.name
  project        = var.project_id
  region         = var.region
  tier           = var.tier
  memory_size_gb = var.memory_size_gb
  redis_version  = var.redis_version

  display_name            = var.display_name
  labels                  = var.labels
  authorized_network      = var.authorized_network
  connect_mode            = var.connect_mode
  reserved_ip_range       = var.reserved_ip_range
  transit_encryption_mode = var.transit_encryption_mode
  auth_enabled            = var.auth_enabled
  redis_configs           = var.redis_configs
  replica_count           = var.tier == "STANDARD_HA" ? var.replica_count : null
  read_replicas_mode      = var.tier == "STANDARD_HA" && var.replica_count > 0 ? var.read_replicas_mode : null

  dynamic "maintenance_policy" {
    for_each = var.maintenance_policy == null ? [] : [var.maintenance_policy]
    content {
      weekly_maintenance_window {
        day = maintenance_policy.value.day
        start_time {
          hours   = maintenance_policy.value.hours
          minutes = maintenance_policy.value.minutes
        }
      }
    }
  }

  dynamic "persistence_config" {
    for_each = var.persistence == null ? [] : [var.persistence]
    content {
      persistence_mode    = persistence_config.value.mode
      rdb_snapshot_period = persistence_config.value.snapshot_period
    }
  }
}
