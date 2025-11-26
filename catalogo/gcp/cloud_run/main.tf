resource "google_cloud_run_service" "service" {
  name     = var.service_name
  project  = var.project_id
  location = var.location

  template {
    spec {
      containers {
        image = var.image

        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public" {
  count    = var.allow_unauthenticated ? 1 : 0
  project  = var.project_id
  location = var.location
  service  = google_cloud_run_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
