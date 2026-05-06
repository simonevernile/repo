output "instance_name" {
  description = "Name of the Cloud SQL instance."
  value       = google_sql_database_instance.postgres.name
}

output "connection_name" {
  description = "Connection name used by clients (e.g. cloud_sql_proxy) to connect to the instance."
  value       = google_sql_database_instance.postgres.connection_name
}

output "self_link" {
  description = "Self link of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.self_link
}

output "public_ip_address" {
  description = "Primary public IPv4 of the instance, or null when public IP is disabled."
  value       = try(google_sql_database_instance.postgres.public_ip_address, null)
}

output "private_ip_address" {
  description = "Private IP of the instance when private_network is configured."
  value       = try(google_sql_database_instance.postgres.private_ip_address, null)
}

output "database" {
  description = "Name of the database created when database_name is provided."
  value       = try(google_sql_database.database[0].name, null)
}

output "generated_postgres_password" {
  description = "Auto-generated postgres password when generate_password is true. Null otherwise."
  value       = try(random_password.postgres[0].result, null)
  sensitive   = true
}
