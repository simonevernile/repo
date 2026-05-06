locals {
  generated_password = var.generate_password ? random_password.postgres[0].result : null
  effective_password = coalesce(var.postgres_password, local.generated_password)
}

resource "random_password" "postgres" {
  count            = var.generate_password ? 1 : 0
  length           = 24
  special          = true
  override_special = "!@#%^*-_=+"
}

resource "google_sql_database_instance" "postgres" {
  name                = var.instance_name
  project             = var.project_id
  database_version    = var.database_version
  region              = var.region
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    disk_autoresize   = var.disk_autoresize

    user_labels = var.labels

    ip_configuration {
      ipv4_enabled    = var.enable_public_ip
      private_network = var.private_network
      ssl_mode        = var.ssl_mode

      dynamic "authorized_networks" {
        for_each = { for net in var.authorized_networks : net.name => net }
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }
    }

    backup_configuration {
      enabled                        = var.backup.enabled
      point_in_time_recovery_enabled = var.backup.point_in_time_recovery_enabled
      start_time                     = var.backup.start_time
      location                       = var.backup.location
      transaction_log_retention_days = var.backup.transaction_log_retention_days
      backup_retention_settings {
        retained_backups = var.backup.retained_backups
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = var.maintenance_window.day
      hour         = var.maintenance_window.hour
      update_track = var.maintenance_window.update_track
    }

    insights_config {
      query_insights_enabled  = var.insights.enabled
      record_application_tags = var.insights.record_application_tags
      record_client_address   = var.insights.record_client_address
      query_string_length     = var.insights.query_string_length
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }
  }
}

resource "google_sql_user" "postgres" {
  count    = local.effective_password == null ? 0 : 1
  name     = "postgres"
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
  password = local.effective_password
}

resource "google_sql_user" "additional" {
  for_each = { for u in var.additional_users : u.name => u }

  name     = each.value.name
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
  password = each.value.password
}

resource "google_sql_database" "database" {
  count    = var.database_name == null ? 0 : 1
  name     = var.database_name
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
}
