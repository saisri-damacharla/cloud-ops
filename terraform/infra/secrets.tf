resource "google_secret_manager_secret" "api_key" {
  secret_id = var.secret_name
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "api_key_v1" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = var.secret_value
}
