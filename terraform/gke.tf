# ==========================================
# Enable GKE API
# ==========================================

resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# ==========================================
# Private GKE Cluster
# ==========================================

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

    enable_private_nodes    = true
    enable_private_endpoint = true

    master_ipv4_cidr_block = "172.16.0.0/28"
  }

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

# ==========================================
# Primary Node Pool
# ==========================================

resource "google_container_node_pool" "primary_nodes" {

  name     = "primary-node-pool"
  cluster  = google_container_cluster.private_cluster.name
  location = var.zone

  node_count = 1

  autoscaling {

    min_node_count = 1
    max_node_count = 3

  }

  management {

    auto_repair  = true
    auto_upgrade = true

  }

  node_config {
    machine_type = "e2-medium"

    disk_size_gb = 100
    disk_type    = "pd-balanced"

    image_type = "COS_CONTAINERD"

    preemptible = true

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }


}
