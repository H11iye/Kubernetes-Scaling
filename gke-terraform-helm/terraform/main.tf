resource "google_container_cluster" "gke" {
  name = var.cluster_name
  location = var.zone # use zone instead of region
  remove_default_node_pool = true
  initial_node_count = 1
  # TO DO - Add network and ip_allocation_policy etc
}

resource "google_container_node_pool" "primary_nodes" {
  name = "primary-pool"
  location = var.zone     # use zone instead of region
  cluster = google_container_cluster.gke.name
  node_count = var.node_count
  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type = "pd-standard" # use cheaper standard persistent disk instead of pd-ssd
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}


# Service account for cloud build or CI/CD pipeline

resource "google_service_account" "cloudbuild" {
  account_id = "cloudbuild-sa"
  display_name = "Cloud Build Service Account"
}

# Roles for pushing images to Artifact Registry
resource "google_project_iam_member" "artifact_registry_roles" {
  for_each = toset([
    "roles/artifactregistry.writer",
    "roles/artifactregistry.reader",
    "roles/storage.admin",
    "roles/viewer",
    "roles/compute.admin",
    "roles/iam.serviceAccountUser",
    "roles/storage.objectAdmin"
  ])
  project = var.project_id
  role = each.key
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# Roles for deploying to GKE
resource "google_project_iam_member" "gke_deployer_roles" {
  for_each = toset([
    "roles/container.developer",
    "roles/container.admin"
  ])
  project = var.project_id
  role = each.key
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}
resource "google_artifact_registry_repository" "express_app_repo" {
  project = var.project_id
  location = var.region
  repository_id = "express-app-repo"
  format = "DOCKER"
}