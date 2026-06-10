#==========================================
# Enable GKE API:
#==========================================
resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# ========================================
# Private GKE Cluster
# ========================================

resource "google_container_cluster" "private_cluster" {

  name     = "my-tf-cluster"
  location = var.zone

  network    = google_compute_network.custom_vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  private_cluster_config {

    # Nodes receive only private IPs
    enable_private_nodes = true

    # Control plane accessible only from VPC
    enable_private_endpoint = true

    # Dedicated CIDR for GKE control plane
    master_ipv4_cidr_block = "172.16.0.0/28"
  }
  # Control who can access the private API endpoint
  master_authorized_networks_config {

    cidr_blocks {
      cidr_block   = "10.0.1.0/24"
      display_name = "admin-subnet"
    }

  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }


  depends_on = [
    google_project_service.container
  ]
}

# ========================================
# Node Pool
# ========================================

resource "google_container_node_pool" "primary_nodes" {

  name     = "primary-node-pool"
  cluster  = google_container_cluster.private_cluster.name
  location = var.zone

  node_count = 1

  node_config {

    machine_type = "e2-medium"

    preemptible = true

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

}