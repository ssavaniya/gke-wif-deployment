resource "google_compute_instance" "my-tf-instance" {
  name         = "my-tf-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.custom_vpc.id
    subnetwork = google_compute_subnetwork.subnet.id

    # No access_config block = No Public IP
  }

  tags = [
    "self-hosted-vm",
    "iap-ssh"
  ]
lifecycle {
  ignore_changes = [
    metadata
  ]
}
}
