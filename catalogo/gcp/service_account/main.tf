resource "google_service_account" "sa" {
  account_id   = var.account_id
  project      = var.project_id
  display_name = var.display_name
  description  = var.description
  disabled     = var.disabled
}

resource "google_project_iam_member" "project_roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_service_account_iam_member" "impersonators" {
  for_each = toset(var.impersonators)

  service_account_id = google_service_account.sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}

resource "google_service_account_key" "key" {
  count = var.create_key ? 1 : 0

  service_account_id = google_service_account.sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
  key_algorithm      = "KEY_ALG_RSA_2048"
}
