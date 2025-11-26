output "service_url" {
  description = "URL pubblico del servizio Cloud Run"
  value       = google_cloud_run_service.service.status[0].url
}
