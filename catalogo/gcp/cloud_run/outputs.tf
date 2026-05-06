output "service_name" {
  description = "Name of the Cloud Run service."
  value       = google_cloud_run_v2_service.service.name
}

output "service_url" {
  description = "Public HTTPS URL of the Cloud Run service."
  value       = google_cloud_run_v2_service.service.uri
}

output "latest_revision" {
  description = "Name of the latest ready revision."
  value       = try(google_cloud_run_v2_service.service.latest_ready_revision, null)
}

output "id" {
  description = "Resource ID of the Cloud Run service."
  value       = google_cloud_run_v2_service.service.id
}
