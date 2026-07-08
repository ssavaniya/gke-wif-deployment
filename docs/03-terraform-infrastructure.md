# Terraform Infrastructure

## Overview

The entire Google Cloud infrastructure for this project is provisioned using **Terraform**, enabling Infrastructure as Code (IaC) and ensuring that the environment can be recreated consistently across multiple deployments.

Terraform manages all core infrastructure components, including networking, compute resources, Kubernetes, and supporting services required for application deployment.

Using Terraform provides several advantages:

- Infrastructure version control
- Repeatable deployments
- Automated provisioning
- Easier maintenance
- Reduced manual configuration
- Production-ready infrastructure management

---

# Infrastructure Components

The following resources are provisioned using Terraform.

```text
Terraform

│

├── VPC Network

├── Subnet

├── Cloud Router

├── Cloud NAT

├── Artifact Registry

├── Private GKE Cluster

├── GKE Node Pool

├── Bastion VM

└── Service Accounts
```

---

# Project Structure

The Terraform configuration is organized into multiple files to improve readability and maintainability.

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
├── artifact-registry.tf
└── service-account.tf
```

Each file is responsible for provisioning a specific set of cloud resources.

---

# Provider Configuration

Terraform uses the Google Cloud provider to interact with Google Cloud APIs.

The provider configuration specifies:

- Project ID
- Region
- Authentication
- Provider version

Terraform communicates directly with Google Cloud APIs during the provisioning process.

---

# Virtual Private Cloud (VPC)

A custom Virtual Private Cloud was created to isolate all project resources.

Instead of using Google's default network, a dedicated VPC provides:

- Better security
- Controlled routing
- Custom firewall rules
- Easier network management

The VPC hosts:

- Private GKE Cluster
- Bastion VM
- Cloud NAT
- Internal networking

---

# Subnet

A custom subnet was created inside the VPC.

The subnet provides IP addresses for:

- Virtual Machines
- GKE Nodes
- Internal communication

Private Google Access is enabled to allow private resources to communicate with Google Cloud services without requiring public IP addresses.

---

# Cloud Router

Cloud Router dynamically manages routing information for Cloud NAT.

Responsibilities include:

- Dynamic route advertisement
- Communication between Cloud NAT and the VPC
- Internet egress support

Although no BGP peers are configured in this project, Cloud Router is required for Cloud NAT.

---

# Cloud NAT

The GKE nodes are deployed without public IP addresses.

Cloud NAT allows private resources to access the internet securely.

Typical outbound traffic includes:

- Pulling Docker images
- Downloading operating system updates
- Accessing Google APIs
- Installing application dependencies

Traffic flow:

```text
Private Node

↓

Cloud NAT

↓

Internet
```

No inbound traffic is permitted through Cloud NAT.

---

# Artifact Registry

Artifact Registry stores Docker container images used by the Kubernetes cluster.

Benefits include:

- Secure image storage
- Versioned images
- Vulnerability scanning integration
- Regional repository
- Integration with GKE

Every application deployment references images stored in Artifact Registry.

---

# Bastion Virtual Machine

A Compute Engine virtual machine is provisioned inside the same VPC as the Kubernetes cluster.

Purpose:

- Cluster administration
- kubectl access
- Helm deployments
- GitHub Actions self-hosted runner

Since the Kubernetes control plane is private, administration must occur from within the VPC.

---

# Private GKE Cluster

A private Google Kubernetes Engine cluster is provisioned.

Key characteristics:

- Private nodes
- Private control plane
- Workload Identity enabled
- IP Alias enabled
- Shielded Nodes
- COS Container-Optimized OS

Private clusters reduce the attack surface by preventing direct public access to cluster nodes.

---

# GKE Node Pool

The cluster uses a dedicated managed node pool.

Configuration includes:

- Spot Virtual Machines
- e2-medium machine type
- Auto Repair
- Auto Upgrade
- Cluster Autoscaler
- Workload Metadata enabled

Spot VMs significantly reduce infrastructure costs while remaining suitable for non-production workloads.

---

# Cluster Autoscaler

Cluster Autoscaler is enabled on the node pool.

Configuration:

- Minimum Nodes: 1
- Maximum Nodes: 3

The autoscaler automatically provisions or removes worker nodes based on pending workloads.

Benefits include:

- Cost optimization
- Automatic scaling
- Improved resource utilization

---

# Workload Identity

Workload Identity is enabled during cluster creation.

This allows Kubernetes workloads and GitHub Actions to authenticate securely without storing service account keys.

Benefits:

- No JSON keys
- Temporary credentials
- IAM integration
- Improved security

---

# Resource Relationships

The infrastructure components are interconnected as shown below.

```text
Terraform

↓

VPC

├── Subnet

│

├── Cloud Router

│

├── Cloud NAT

│

├── Bastion VM

│

└── Private GKE Cluster

        │

        ├── Node Pool

        │

        └── Workloads
```

---

# Terraform Workflow

Infrastructure changes follow a standard Terraform workflow.

Initialize Terraform

```bash
terraform init
```

Review execution plan

```bash
terraform plan
```

Provision infrastructure

```bash
terraform apply
```

Destroy infrastructure

```bash
terraform destroy
```

---

# Benefits of Infrastructure as Code

Using Terraform provides several operational advantages.

- Infrastructure is reproducible.
- Resources remain version controlled.
- Changes are peer reviewed.
- Drift is minimized.
- Deployments become predictable.
- Disaster recovery becomes easier.

---

# Key Takeaways

By provisioning infrastructure through Terraform, the project achieves:

- Fully automated cloud provisioning
- Secure private networking
- Production-style Kubernetes infrastructure
- Cost optimization through Spot VMs
- Repeatable deployments
- Infrastructure version control
- Foundation for GitOps and CI/CD
