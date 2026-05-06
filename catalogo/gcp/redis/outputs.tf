output "host" {
  description = "Endpoint host of the Redis instance."
  value       = google_redis_instance.redis.host
}

output "port" {
  description = "Port of the Redis instance."
  value       = google_redis_instance.redis.port
}

output "current_location_id" {
  description = "Zone where the master instance is provisioned."
  value       = google_redis_instance.redis.current_location_id
}

output "read_endpoint" {
  description = "Endpoint host of the read replicas (STANDARD_HA + read replicas only)."
  value       = try(google_redis_instance.redis.read_endpoint, null)
}

output "auth_string" {
  description = "AUTH string when auth_enabled is true."
  value       = google_redis_instance.redis.auth_string
  sensitive   = true
}

output "id" {
  description = "Resource ID of the Redis instance."
  value       = google_redis_instance.redis.id
}
