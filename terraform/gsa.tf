resource "google_service_account" "storage_reader" {
  account_id   = "storage-reader"
  display_name = "Storage Reader Service Account"
}
resource "google_project_iam_member" "storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.storage_reader.email}"
}