data "google_compute_network" "default" {
  name = var.vpc_name
}

data "google_compute_subnetwork" "default" {
  name   = var.subnetwork
  region = var.region
}

resource "google_container_cluster" "default" {
  name     = "${var.name}-gke-cluster-${var.env}"
  location = var.region

  network    = data.google_compute_network.default.self_link
  subnetwork = data.google_compute_subnetwork.default.self_link

  # Enable Autopilot for this cluster
  enable_autopilot = true

  # Configuration of cluster IP allocation for VPC-native clusters
  #  ip_allocation_policy {
  #    cluster_secondary_range_name  = "pods"
  #    services_secondary_range_name = "services"
  #  }

  # Configuration options for the Release channel feature, which provide more control over automatic upgrades of your GKE clusters.
  release_channel {
    channel = "STABLE"
  }
}