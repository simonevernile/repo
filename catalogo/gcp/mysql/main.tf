resource "google_sql_database_instance" "mysql" {
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

resource "google_sql_user" "root" {
  count    = var.root_password == null ? 0 : 1
  name     = "root"
  project  = var.project_id
  instance = google_sql_database_instance.mysql.name
  host     = "%"
  password = var.root_password
}

resource "google_sql_database" "database" {
  count     = var.database_name == null ? 0 : 1
  name      = var.database_name
  project   = var.project_id
  instance  = google_sql_database_instance.mysql.name
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}
