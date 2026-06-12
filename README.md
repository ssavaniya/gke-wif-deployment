Final Architecture:

Developer
↓
Git Push
↓
GitHub
↓
GitHub Actions
↓
Workload Identity Federation
↓
Google Cloud

Cloud Build
↓
Artifact Registry
↓
Private GKE Cluster

Private GKE Cluster
↓
Deployment
↓
ReplicaSet
↓
Pods

Service
↓
Load Balancing
↓
Application
