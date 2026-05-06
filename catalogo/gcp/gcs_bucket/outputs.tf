output "name" {
  description = "Bucket name."
  value       = google_storage_bucket.bucket.name
}

output "url" {
  description = "gs:// URL of the bucket."
  value       = google_storage_bucket.bucket.url
}

output "self_link" {
  description = "Self link of the bucket."
  value       = google_storage_bucket.bucket.self_link
}

output "location" {
  description = "Effective bucket location."
  value       = google_storage_bucket.bucket.location
}
