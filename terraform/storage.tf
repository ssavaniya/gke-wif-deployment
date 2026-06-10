resource "google_storage_bucket" "test" {
  name                        = "${var.project_id}-wi-test"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "reader" {
  bucket = google_storage_bucket.test.name
  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:${google_service_account.storage_reader.email}"
}