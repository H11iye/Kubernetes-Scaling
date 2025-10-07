variable "project_id" {
 type = string

}

variable "region" {
  type = string
  default = "us-central1"
}
variable "zone" {
  type = string
  default = "us-central1-a"
}

variable "cluster_name" {
  type = string
  default = "gke-terraform-helm-cluster"
}

variable "node_count" {
  type = number
  default = 2
}

variable "machine_type" {
  type = string
  default = "e2-medium"
}

variable "disk_size_gb" {
  type = number
  default = 50
}