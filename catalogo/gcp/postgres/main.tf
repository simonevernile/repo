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

    ip_configuration {
      ipv4_enabled = var.enable_public_ip
    }
  }
}

resource "google_sql_user" "postgres" {
  count    = var.postgres_password == null ? 0 : 1
  name     = "postgres"
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
  password = var.postgres_password
}

resource "google_sql_database" "database" {
  count    = var.database_name == null ? 0 : 1
  name     = var.database_name
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
}
