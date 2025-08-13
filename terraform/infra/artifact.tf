resource "google_artifact_registry_repository" "repo" {
  repository_id = var.artifact_repo
  description   = "Docker images for ops demo"
  format        = "DOCKER"
  location      = var.region
}
