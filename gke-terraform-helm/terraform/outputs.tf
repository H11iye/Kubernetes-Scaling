output "cluster_name" {
  description = "GKE cluster name"
  value = google_container_cluster.gke.name
}

output "cluster_location" {
  description = "cluster location (region or zone)"
  value = google_container_cluster.gke.location
}

output "workload_identity_provider" {
  description = "Workload Identity Provider full resource name"
  value = google_iam_workload_identity_pool.github_pool.name
}