terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.30"
    }
  }
}

provider "google" {
  project = var.project_id
}

resource "google_storage_bucket" "tf_state" {
  name                        = var.bucket_name
  location                    = var.location
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }
}

output "state_bucket" {
  value = google_storage_bucket.tf_state.name
}
