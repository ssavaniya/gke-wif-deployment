# Private Google Kubernetes Engine (GKE) Cluster

## Overview

The application platform is hosted on a **Private Google Kubernetes Engine (GKE)** cluster running in Google Cloud Platform.

Unlike a public Kubernetes cluster, both the Kubernetes worker nodes and the control plane remain private inside a custom VPC. Only authorized resources inside the VPC can communicate with the cluster, providing a secure and production-like environment.

The cluster hosts multiple workloads including:

- Spring Boot application
- NGINX Ingress Controller
- cert-manager
- Grafana
- Monitoring components

The infrastructure closely resembles how modern Platform Engineering teams deploy workloads in production.

---

# Why a Private GKE Cluster?

Public Kubernetes clusters expose worker nodes or the Kubernetes API server to the internet.

A private cluster keeps all critical components inside the VPC while allowing only controlled access from trusted networks.

Benefits include:

- Reduced attack surface
- Improved security posture
- Internal-only cluster administration
- Better compliance with enterprise security standards
- Secure communication between workloads

---

# Cluster Architecture

```text
                           Internet
                               │
                               │
                     HTTPS (443)
                               │
                      External Load Balancer
                               │
                     NGINX Ingress Controller
                               │
                    ┌──────────┴──────────┐
                    │                     │
              Spring Boot App       Grafana
                    │                     │
              ClusterIP Service    ClusterIP Service
                    │                     │
                   Pods                 Pods
                    │
            Google Kubernetes Engine
                    │
           Private Worker Nodes
                    │
          Private Control Plane
                    │
              Bastion VM (kubectl)
                    │
                 Cloud NAT
                    │
                 Internet
```

---

# Cluster Configuration

| Feature | Configuration |
|----------|---------------|
| Cluster Type | Private GKE |
| Region | us-central1 |
| Zone | us-central1-a |
| Networking | VPC Native |
| Node Image | COS Containerd |
| Private Nodes | Enabled |
| Private Control Plane | Enabled |
| Workload Identity | Enabled |
| Shielded Nodes | Enabled |

---

# Private Nodes

Worker nodes are provisioned without public IP addresses.

This ensures:

- Nodes cannot be accessed directly from the internet.
- SSH access to nodes is not exposed publicly.
- All outbound internet access occurs through Cloud NAT.

Typical outbound traffic includes:

- Pulling container images
- Downloading package updates
- Accessing Google APIs
- Communicating with Artifact Registry

---

# Private Control Plane

The Kubernetes API server is also private.

Only trusted resources inside the VPC can communicate with the cluster.

For this project, cluster administration is performed from a Compute Engine virtual machine (Bastion VM) located in the same VPC.

Common administrative tasks include:

- kubectl
- Helm deployments
- Troubleshooting
- Viewing logs
- Installing Kubernetes components

Example:

```bash
gcloud container clusters get-credentials my-tf-cluster \
  --zone us-central1-a
```

Verify connectivity:

```bash
kubectl get nodes
```

---

# Managed Node Pool

The cluster uses a dedicated managed node pool.

Configuration includes:

- e2-medium machine type
- Spot Virtual Machines
- Auto Repair
- Auto Upgrade
- Workload Metadata enabled

Using managed node pools allows Google Kubernetes Engine to automatically maintain worker nodes.

---

# Spot Virtual Machines

Worker nodes are created using Spot Virtual Machines to reduce infrastructure costs.

Advantages:

- Lower compute cost
- Ideal for learning environments
- Fully managed by GKE

Trade-offs:

- Nodes can be reclaimed by Google Cloud.
- Workloads should tolerate interruptions.

---

# Cluster Autoscaler

Cluster Autoscaler automatically adjusts the number of worker nodes based on workload demand.

Configuration:

| Minimum Nodes | Maximum Nodes |
|---------------|---------------|
| 1 | 3 |

Benefits include:

- Automatic scaling
- Improved resource utilization
- Cost optimization

---

# Workload Identity

Workload Identity is enabled on the cluster.

Instead of storing Google Cloud service account keys inside Kubernetes, workloads authenticate securely using Google IAM.

Benefits:

- No long-lived credentials
- Temporary access tokens
- Improved security
- Native IAM integration

GitHub Actions also authenticates using **Workload Identity Federation**, eliminating the need for JSON service account keys.

---

# Kubernetes Networking

The cluster uses VPC-native networking with Alias IP ranges.

Separate CIDR ranges are allocated for:

- Nodes
- Pods
- Services

Benefits include:

- Better scalability
- Native Google Cloud networking
- Simplified routing
- Improved network isolation

---

# Ingress and External Access

External traffic enters the cluster through the NGINX Ingress Controller.

Ingress provides:

- Host-based routing
- TLS termination
- Reverse proxy
- Load balancing

Current public endpoints include:

| Application | URL |
|-------------|-------------------------------------------|
| Spring Boot Application | https://app.devopswithsachin.in |
| Grafana Dashboard | https://grafana.devopswithsachin.in |

TLS certificates are automatically issued and renewed using **cert-manager** with **Let's Encrypt**.

---

# Application Deployment Flow

Applications are deployed using Helm.

Deployment hierarchy:

```text
Helm

↓

Deployment

↓

ReplicaSet

↓

Pods

↓

ClusterIP Service

↓

NGINX Ingress

↓

Users
```

Kubernetes automatically performs rolling updates with zero manual intervention.

---

# High Availability Features

Although this project is intended for learning, several production-grade Kubernetes capabilities are enabled:

- ReplicaSets recreate failed Pods
- Rolling Updates
- Self-healing Pods
- Managed node upgrades
- Managed node repairs
- Cluster Autoscaler
- Automatic certificate renewal

---

# Useful Kubernetes Commands

View nodes

```bash
kubectl get nodes
```

View Pods

```bash
kubectl get pods -A
```

View Deployments

```bash
kubectl get deployments -A
```

View Services

```bash
kubectl get svc -A
```

View Ingress

```bash
kubectl get ingress -A
```

View Certificates

```bash
kubectl get certificate -A
```

View Ingress Controller

```bash
kubectl get pods -n ingress-nginx
```

---

# Operational Benefits

This private GKE cluster provides:

- Private Kubernetes environment
- Secure networking
- Managed control plane
- Automatic node management
- Auto Repair
- Auto Upgrade
- Cluster Autoscaler
- Workload Identity
- HTTPS with Let's Encrypt
- NGINX Ingress
- Production-style deployment architecture

---

# Key Takeaways

The private GKE cluster is the core of this platform engineering project.

Combined with Terraform, GitHub Actions, Helm, Workload Identity Federation, cert-manager, NGINX Ingress, and Let's Encrypt, it delivers a secure, automated, and production-oriented Kubernetes platform suitable for hosting modern cloud-native applications.
