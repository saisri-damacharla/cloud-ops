resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr
}

# Allow GKE master -> nodes
resource "google_compute_firewall" "gke_master_to_nodes" {
  name    = "gke-master-to-nodes"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["10250"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"] # GKE master IP ranges
}
