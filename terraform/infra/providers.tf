terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.30"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.28"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# The Kubernetes provider will be configured after cluster is created (data sources).
