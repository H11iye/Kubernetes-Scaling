resource "google_container_cluster" "gke" {
  name = var.cluster_name
  location = var.zone # use zone instead of region
  remove_default_node_pool = true
  initial_node_count = 1
  # TO DO - Add network and ip_allocation_policy etc
  # Enable workload identity (required for K8s-> GCP access)
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Enable shielded nodes, release channel, etc for production
  release_channel {
    channel = "STABLE"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name = "primary-pool"
  location = var.zone     # use zone instead of region
  cluster = google_container_cluster.gke.name
  node_count = var.node_count

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type = "pd-standard" # use cheaper standard persistent disk instead of pd-ssd
    # protect nodes metadata and enable per-pod metadata (workload identity)
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

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
    "roles/storage.objectAdmin",
    "roles/run.developer"
  ])
  project = var.project_id
  role = each.key
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_service_account_iam_member" "allow_wif" {
  service_account_id = google_service_account.cloudbuild.name # full resource name
  role = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/H11iye/Kubernetes-Scaling"
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

resource "google_iam_workload_identity_pool" "github_pool" {
  provider = google-beta.google-beta
 workload_identity_pool_id = "github-pool-v2"
 display_name = "GitHub Actions Pool v2" 
 description = "Pool for GitHub Actions OIDC tokens"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  provider = google-beta.google-beta
  workload_identity_pool_id = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name = "GitHub OIDC Provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # Map GitHub OIDC claims 
  attribute_mapping = {
    "google.subject" = "assertion.sub"
    "attribute.actor" = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.branch" = "assertion.ref"
  }
  # Allow only tokens from this repo and branch
  attribute_condition = "assertion.repository == \"H11iye/Kubernetes-Scaling\" && assertion.ref == \"refs/heads/main\""
}