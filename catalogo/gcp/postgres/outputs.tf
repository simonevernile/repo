output "connection_name" {
  description = "Connection name used by clients to connect to the instance"
  value       = google_sql_database_instance.postgres.connection_name
}

output "self_link" {
  description = "Self link of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.self_link
}

output "database" {
  description = "Name of the database created when database_name is provided"
  value       = try(google_sql_database.database[0].name, null)
}
