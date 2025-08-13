# Ensure APIs are enabled
resource "google_project_service" "services" {
  for_each = toset([
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "monitoring.googleapis.com",
    "cloudbuild.googleapis.com"
  ])
  service = each.key
  disable_on_destroy = false
}
