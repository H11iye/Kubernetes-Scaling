resource "google_container_cluster" "gke" {
  name = var.cluster_name
  location = var.region 
  remove_default_node_pool = true
  initial_node_count = 1
  # TO DO - Add network and ip_allocation_policy etc
}

resource "google_container_node_pool" "primary_nodes" {
  name = "primary-pool"
  location = var.region
  cluster = google_container_cluster.gke.name
  node_count = var.node_count
  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

