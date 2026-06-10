# ========================================
# Enable Compute API
# ========================================
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}
# ========================================
# Enable IAP API to allow SSH
# ========================================
resource "google_project_service" "iap" {
  service            = "iap.googleapis.com"
  disable_on_destroy = false
}

# ========================================
# Create a custom VPC
# ========================================

resource "google_compute_network" "custom_vpc" {
  name                    = "my-tf-vpc"
  auto_create_subnetworks = false
  depends_on = [
    google_project_service.compute
  ]
}

# ========================================
# Create a Subnetwork
# ========================================
resource "google_compute_subnetwork" "subnet" {
  name                     = "my-tf-subnet"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.region
  network                  = google_compute_network.custom_vpc.id
  private_ip_google_access = true # To allow access to Google APIs

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = "10.2.0.0/20"
  }
}

# ========================================
# Allow SSH via IAP
# ========================================

resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]

  target_tags = ["iap-ssh"]
}