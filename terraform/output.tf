# ========================================
# VPC Outputs
# ========================================

output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.custom_vpc.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.custom_vpc.id
}

output "vpc_self_link" {
  description = "The URI of the VPC"
  value       = google_compute_network.custom_vpc.self_link
}

# ========================================
# Subnet Outputs
# ========================================

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_cidr" {
  description = "Subnet CIDR range"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

# ========================================
# VM Outputs
# ========================================

output "vm_name" {
  description = "VM name"
  value       = google_compute_instance.my-tf-instance.name
}

output "vm_private_ip" {
  description = "VM private IP"
  value       = google_compute_instance.my-tf-instance.network_interface[0].network_ip
}

# ========================================
# GKE Outputs
# ========================================

output "cluster_name" {
  description = "GKE Cluster Name"
  value       = google_container_cluster.private_cluster.name
}

output "cluster_location" {
  description = "GKE Cluster Location"
  value       = google_container_cluster.private_cluster.location
}

output "private_endpoint" {
  description = "Private Control Plane Endpoint"
  value       = google_container_cluster.private_cluster.private_cluster_config[0].private_endpoint
}

output "master_ipv4_cidr_block" {
  description = "Control Plane CIDR"
  value       = google_container_cluster.private_cluster.private_cluster_config[0].master_ipv4_cidr_block
}

# ========================================
# Cloud Router Outputs
# ========================================

output "cloud_router_name" {
  description = "Cloud Router Name"
  value       = google_compute_router.nat_router.name
}

# ========================================
# Cloud NAT Outputs
# ========================================

output "cloud_nat_name" {
  description = "Cloud NAT Name"
  value       = google_compute_router_nat.nat.name
}