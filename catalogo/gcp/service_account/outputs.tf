output "email" {
  description = "Email address of the service account."
  value       = google_service_account.sa.email
}

output "id" {
  description = "Resource ID of the service account."
  value       = google_service_account.sa.id
}

output "name" {
  description = "Fully qualified resource name (projects/.../serviceAccounts/...)."
  value       = google_service_account.sa.name
}

output "unique_id" {
  description = "Stable numeric unique ID."
  value       = google_service_account.sa.unique_id
}

output "member" {
  description = "Pre-formatted IAM member string (serviceAccount:<email>)."
  value       = "serviceAccount:${google_service_account.sa.email}"
}

output "private_key" {
  description = "Base64-encoded JSON key when create_key is true. Null otherwise."
  value       = try(google_service_account_key.key[0].private_key, null)
  sensitive   = true
}
