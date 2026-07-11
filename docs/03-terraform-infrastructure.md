# Terraform Infrastructure

## Overview

This project uses **Terraform** to provision the core Google Cloud infrastructure required to run a private Kubernetes platform. Infrastructure as Code (IaC) ensures that resources can be created consistently, maintained through version control, and recreated whenever required.

Terraform is responsible for provisioning the networking layer, private GKE cluster, Compute Engine VM, Cloud Router, Cloud NAT, and supporting infrastructure.

Some supporting services, such as **Cloud DNS** and **Artifact Registry**, were intentionally created manually through the Google Cloud Console to better understand both manual and Infrastructure as Code approaches.

---

# Infrastructure Provisioned by Terraform

The following resources are created using Terraform.

```text
Terraform

│
├── Custom VPC
├── Private Subnet
├── Cloud Router
├── Cloud NAT
├── Private GKE Cluster
├── GKE Node Pool
├── Bastion VM
└── Firewall Rules
```

---

# Resources Created Manually

The following resources are **not** managed by Terraform in this project.

| Resource | Purpose |
|----------|---------|
| Artifact Registry | Stores Docker images |
| Cloud DNS | Hosts DNS zone and domain records |
| Workload Identity Federation | GitHub authentication |
| IAM Role Bindings | Required for GitHub Actions |
| cert-manager | TLS certificate automation |
| NGINX Ingress Controller | External traffic routing |

This hybrid approach was intentionally used to gain experience with both Terraform-managed and manually configured Google Cloud services.

---

# Terraform Project Structure

The Terraform configuration is organized into multiple files for better readability and maintenance.

```text
terraform/

├── provider.tf
├── variables.tf
├── outputs.tf
├── vpc.tf
├── router.tf
├── nat.tf
├── gce.tf
├── gke.tf
├── firewall.tf
└── terraform.tfvars
```

Each file manages a specific part of the infrastructure.

---

# Provider Configuration

Terraform uses the Google Cloud Provider to communicate with Google Cloud APIs.

The provider configuration defines:

- Google Cloud Project
- Region
- Authentication
- Provider version

Terraform authenticates using the currently logged-in Google Cloud account.

---

# Custom VPC

A dedicated Virtual Private Cloud (VPC) isolates all project resources from Google's default network.

Benefits include:

- Network isolation
- Better security
- Custom routing
- Controlled firewall rules
- Production-style networking

The VPC contains:

- Private GKE Cluster
- Compute Engine administration VM
- Cloud Router
- Cloud NAT

---

# Private Subnet

A custom subnet provides IP addresses for all private resources.

Private Google Access is enabled, allowing private resources to communicate with Google Cloud services without requiring public IP addresses.

The subnet hosts:

- GKE Nodes
- Compute Engine VM

---

# Firewall Rules

Terraform provisions firewall rules required for:

- SSH access to the administration VM
- Internal communication within the VPC
- Kubernetes node communication

Firewall rules are restricted to the minimum required access wherever possible.

---

# Cloud Router

Cloud Router enables Cloud NAT to provide outbound internet connectivity for private resources.

Responsibilities include:

- Dynamic route management
- NAT integration
- Internet egress support

Although BGP peers are not configured, Cloud Router is mandatory when using Cloud NAT.

---

# Cloud NAT

The Kubernetes nodes and Compute Engine VM do not require public IP addresses.

Cloud NAT allows private resources to securely access the internet for outbound traffic such as:

- Downloading operating system updates
- Pulling container images
- Accessing Google APIs
- Installing application dependencies

Traffic flow:

```text
Private Resources

        │
        ▼

Cloud NAT

        │
        ▼

Internet
```

Cloud NAT only allows outbound connections and does not expose internal resources to the internet.

---

# Compute Engine Administration VM

A private Compute Engine VM is deployed inside the same VPC as the Kubernetes cluster.

This VM is used for:

- Kubernetes administration
- kubectl access
- Helm deployments
- GitHub Actions self-hosted runner
- Troubleshooting

Since the GKE control plane is private, cluster management is performed from this VM.

---

# Private GKE Cluster

Terraform provisions a private Google Kubernetes Engine cluster.

Key features include:

- Private Nodes
- Private Control Plane
- IP Alias Networking
- Workload Identity enabled
- Shielded GKE Nodes
- Container-Optimized OS

Private clusters significantly reduce the attack surface by preventing direct public access to worker nodes.

---

# GKE Node Pool

The cluster uses a managed node pool.

Configuration includes:

- e2-medium machine type
- Spot Virtual Machines
- Auto Repair
- Auto Upgrade
- Cluster Autoscaler

Spot VMs help reduce infrastructure costs while remaining suitable for development and learning environments.

---

# Cluster Autoscaler

Cluster Autoscaler automatically adjusts the number of worker nodes based on workload demand.

Configuration:

- Minimum Nodes: 1
- Maximum Nodes: 3

Benefits include:

- Automatic scaling
- Improved resource utilization
- Lower infrastructure costs

---

# Infrastructure Relationship

The deployed infrastructure follows the architecture below.

```text
Terraform

        │
        ▼

Custom VPC

        │
        ├───────────────┐
        │               │
        ▼               ▼

Private Subnet     Cloud Router
        │               │
        │               ▼
        │          Cloud NAT
        │
        ├───────────────┐
        │               │
        ▼               ▼

Compute VM     Private GKE Cluster
                       │
                       ▼
                 Managed Node Pool
                       │
                       ▼
                Kubernetes Workloads
```

---

# Terraform Workflow

Terraform follows the standard Infrastructure as Code lifecycle.

Initialize Terraform

```bash
terraform init
```

Review planned changes

```bash
terraform plan
```

Create or update infrastructure

```bash
terraform apply
```

Destroy infrastructure

```bash
terraform destroy
```

---

# Benefits of Using Terraform

Using Terraform provides several advantages:

- Infrastructure version control
- Repeatable deployments
- Consistent environments
- Easier maintenance
- Reduced manual configuration
- Simplified disaster recovery

---

# Key Takeaways

Terraform provides the foundation of the platform by provisioning the core infrastructure required to run a secure private Kubernetes environment.

In this project Terraform provisions:

- Custom VPC
- Private Subnet
- Firewall Rules
- Cloud Router
- Cloud NAT
- Private GKE Cluster
- Managed Node Pool
- Compute Engine Administration VM

Additional services such as Cloud DNS, Artifact Registry, Workload Identity Federation, cert-manager, and the NGINX Ingress Controller were configured manually to gain hands-on experience with Google Cloud administration before automating them in future iterations.
