# Workload Identity: create GSAs and bind to roles
resource "google_service_account" "publisher" {
  account_id   = "publisher-sa"
  display_name = "Publisher GSA"
}

resource "google_service_account" "worker" {
  account_id   = "worker-sa"
  display_name = "Worker GSA"
}

# Permissions for publisher (publish to Pub/Sub, read secret)
resource "google_project_iam_member" "publisher_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.publisher.email}"
}

resource "google_project_iam_member" "publisher_secret" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.publisher.email}"
}

# Permissions for worker (subscribe, read secret)
resource "google_project_iam_member" "worker_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.worker.email}"
}

resource "google_project_iam_member" "worker_secret" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.worker.email}"
}
