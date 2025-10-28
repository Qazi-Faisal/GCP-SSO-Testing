resource "google_service_account" "app_service_account" {
  account_id   = "${var.project_name}-sa"
  display_name = "App Service Account"
}
resource "google_project_iam_member" "app_sa_roles" {
  for_each = toset(var.service_account_roles)
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.app_service_account.email}"
}