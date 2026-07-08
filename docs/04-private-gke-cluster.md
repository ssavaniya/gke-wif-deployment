# Private Google Kubernetes Engine (GKE) Cluster

## Overview

The application is deployed on a **Private Google Kubernetes Engine (GKE)** cluster.

Unlike a public Kubernetes cluster, a private GKE cluster restricts access to both the worker nodes and the Kubernetes control plane, significantly improving security.

This architecture closely resembles production environments used by enterprise organizations.

---

# Why a Private Cluster?

A public Kubernetes cluster exposes worker nodes or the Kubernetes API server to the internet.

A private cluster keeps both inside the Virtual Private Cloud (VPC), allowing access only from authorized internal networks.

Benefits include:

- Reduced attack surface
- Improved network security
- Internal-only cluster administration
- Better compliance with enterprise security standards
- Secure communication between workloads

---

# Cluster Architecture

```text
                    Internet
                        │
                        │
               Cloud NAT (Outbound Only)
                        │
────────────────────────────────────────────────────

                Google Cloud VPC

        ┌─────────────────────────────┐
        │                             │
        │   Bastion VM                │
        │        │                    │
        │        │ kubectl            │
        │        ▼                    │
        │  Private GKE Control Plane  │
        │             │               │
        │             ▼               │
        │        Worker Nodes         │
        │             │               │
        │             ▼               │
        │          Kubernetes Pods    │
        │                             │
        └─────────────────────────────┘
```

---

# Cluster Configuration

The cluster was created with the following characteristics:

| Feature | Configuration |
|----------|---------------|
| Cluster Type | Private GKE |
| Region | us-central1 |
| Node Location | us-central1-a |
| Kubernetes Version | Current Stable Release |
| Image Type | COS Containerd |
| Networking | VPC Native |
| Pod Networking | Alias IP |
| Workload Identity | Enabled |
| Shielded Nodes | Enabled |

---

# Private Nodes

Worker nodes are created **without public IP addresses**.

Because of this:

- Nodes cannot be accessed directly from the internet.
- External systems cannot SSH into the nodes.
- All cluster administration occurs from resources inside the VPC.

Outbound internet access is provided through Cloud NAT.

---

# Private Control Plane

The Kubernetes API server is also private.

This means:

- kubectl cannot connect from arbitrary networks.
- Only trusted internal networks may communicate with the control plane.
- Cloud Shell cannot directly manage the cluster.

For this project, a Compute Engine VM inside the VPC acts as the administration host.

---

# Cluster Administration

The Bastion VM is responsible for managing the Kubernetes cluster.

Typical administrative tasks include:

- Running kubectl
- Installing Helm charts
- Viewing logs
- Managing deployments
- Troubleshooting workloads

Example:

```bash
gcloud container clusters get-credentials my-tf-cluster \
    --zone us-central1-a \
    --project proserv-task02
```

Verify cluster connectivity:

```bash
kubectl get nodes
```

---

# Node Pool

The cluster uses a dedicated managed node pool.

Configuration:

- Machine Type: e2-medium
- Spot Virtual Machines
- Container-Optimized OS
- Auto Repair enabled
- Auto Upgrade enabled

Managed node pools simplify lifecycle management by allowing Google Kubernetes Engine to handle node maintenance automatically.

---

# Spot Virtual Machines

The worker nodes use **Spot Virtual Machines**.

Advantages:

- Significantly lower cost
- Suitable for development and testing
- Managed automatically by GKE

Trade-offs:

- Nodes may be reclaimed by Google Cloud.
- Applications should be resilient to node termination.

For production workloads, organizations often combine Spot nodes with regular nodes.

---

# Cluster Autoscaler

Cluster Autoscaler is enabled.

Configuration:

| Minimum Nodes | Maximum Nodes |
|---------------|---------------|
| 1 | 3 |

When workload demand increases:

```text
More Pods

↓

Insufficient Capacity

↓

Cluster Autoscaler

↓

New Worker Node

↓

Pods Scheduled
```

When workloads decrease, unused nodes are removed automatically.

Benefits:

- Cost optimization
- Improved scalability
- Efficient resource utilization

---

# Workload Identity

Workload Identity is enabled on the cluster.

Rather than storing long-lived service account keys inside Kubernetes, workloads receive temporary credentials from Google Cloud IAM.

Benefits:

- No service account keys
- Improved security
- IAM integration
- Short-lived credentials
- Recommended by Google

Workload Identity is also used by GitHub Actions through Workload Identity Federation.

---

# Kubernetes Networking

The cluster uses **VPC-native networking**.

Separate IP ranges are allocated for:

- Nodes
- Pods
- Services

This provides:

- Better scalability
- Simplified routing
- Improved network isolation

Traffic flows internally without requiring overlay networking.

---

# Workload Scheduling

Applications are deployed onto Kubernetes worker nodes.

```text
Deployment

↓

ReplicaSet

↓

Pods

↓

Worker Nodes
```

The Kubernetes Scheduler automatically determines which node should run each Pod.

---

# High Availability

Even though this environment is intended for learning, Kubernetes automatically provides several high availability features:

- ReplicaSets recreate failed Pods.
- Deployments support rolling updates.
- Nodes are automatically repaired.
- Failed containers restart automatically.
- Cluster Autoscaler adds capacity when required.

---

# Cluster Verification Commands

View cluster nodes

```bash
kubectl get nodes
```

View node details

```bash
kubectl describe node <NODE_NAME>
```

View Pods

```bash
kubectl get pods
```

View Deployments

```bash
kubectl get deployments
```

View Services

```bash
kubectl get svc
```

View Ingress

```bash
kubectl get ingress
```

---

# Operational Benefits

Using a private GKE cluster provides:

- Secure Kubernetes environment
- Internal-only administration
- Reduced attack surface
- Managed Kubernetes control plane
- Automatic node management
- Automatic upgrades
- Automatic repairs
- Native autoscaling
- Enterprise-ready architecture

---

# Key Takeaways

The private GKE cluster serves as the foundation of the application platform.

Combined with Terraform, GitHub Actions, Helm, Artifact Registry, and Workload Identity Federation, it provides a secure, automated, and production-oriented Kubernetes environment capable of supporting modern cloud-native applications.
