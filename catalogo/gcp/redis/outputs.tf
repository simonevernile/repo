output "host" {
  description = "Endpoint host dell'istanza Redis"
  value       = google_redis_instance.redis.host
}

output "port" {
  description = "Porta dell'istanza Redis"
  value       = google_redis_instance.redis.port
}

output "auth_string" {
  description = "Stringa di autenticazione quando auth_enabled è true"
  value       = google_redis_instance.redis.auth_string
  sensitive   = true
}
