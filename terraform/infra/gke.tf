resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.region

  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  ip_allocation_policy {}
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-pool"
  location   = var.region
  cluster    = google_container_cluster.gke.name

  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }

  node_config {
    machine_type = "e2-standard-4"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    labels = {
      env = "ops-demo"
    }
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
