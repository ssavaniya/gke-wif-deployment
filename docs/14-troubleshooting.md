# Troubleshooting Guide

## Overview

Building a production-ready CI/CD platform involves troubleshooting issues across multiple technologies.

This document summarizes the most significant problems encountered during the project, their root causes, and the resolutions implemented.

---

# Terraform

## Issue

Terraform failed while creating infrastructure.

### Symptoms

- Resource creation failed
- Dependency errors
- API not enabled

### Resolution

- Enable required Google Cloud APIs
- Verify project configuration
- Execute:

```bash
terraform init

terraform plan

terraform apply
```

---

# Private GKE Cluster Access

## Issue

Unable to connect to the Kubernetes cluster from Cloud Shell.

### Cause

The cluster uses a private control plane.

Only resources inside the VPC can access the Kubernetes API.

### Resolution

Use the Compute Engine VM inside the VPC.

```bash
gcloud compute ssh my-tf-instance

gcloud container clusters get-credentials my-tf-cluster \
--zone us-central1-a
```

---

# Java Version

## Issue

Application failed to build.

### Error

```
release version 21 not supported
```

### Cause

Project targeted Java 21 while the build environment used Java 17.

### Resolution

Configure the project for Java 17.

Verify:

```bash
java -version

javac -version
```

---

# Docker Push

## Issue

Docker image could not be pushed to Artifact Registry.

### Error

```
connect: connection refused
```

### Cause

Docker push from the development environment failed due to networking limitations.

### Resolution

Replace local Docker push with Google Cloud Build.

---

# Cloud Build Permissions

## Issue

Cloud Build completed the image build but failed to push.

### Error

```
artifactregistry.repositories.uploadArtifacts denied
```

### Cause

Cloud Build service account lacked permission to upload artifacts.

### Resolution

Grant:

```
Artifact Registry Writer
```

to the Cloud Build service account.

---

# Git Authentication

## Issue

Git push failed.

### Cause

GitHub no longer supports password-based Git authentication.

### Resolution

Use SSH authentication.

Generate SSH key:

```bash
ssh-keygen -t ed25519
```

Verify:

```bash
ssh -T git@github.com
```

---

# Workload Identity Federation

## Issue

GitHub Actions authentication failed.

### Symptoms

- Unauthorized
- Permission denied
- Invalid principal

### Resolution

Verify:

- Workload Identity Pool
- Provider
- IAM bindings
- Service Account permissions

Confirm GitHub repository matches the configured provider.

---

# GitHub Self-Hosted Runner

## Issue

Runner stopped after VM reboot.

### Cause

Runner started manually.

### Resolution

Configure the runner as a systemd service.

Verify:

```bash
systemctl status actions.runner.*
```

---

# Vulnerability Scanning

## Issue

Pipeline failed after image scan.

### Cause

Critical or High vulnerabilities detected.

### Resolution

Upgrade affected dependencies.

Examples:

- Tomcat
- Jackson
- Operating system packages

Rebuild image and rerun the pipeline.

---

# Kubernetes Deployment

## Issue

Deployment rollout failed.

### Verify

```bash
kubectl rollout status deployment/hello-gke
```

Inspect Pods:

```bash
kubectl get pods

kubectl describe pod POD_NAME

kubectl logs POD_NAME
```

---

# Service Connectivity

## Issue

Application unreachable.

### Verify

```bash
kubectl get svc

kubectl get endpoints
```

Ensure:

- Service selector matches Pod labels
- Pod is healthy
- Endpoints exist

---

# Ingress

## Issue

Ingress created but application unreachable.

### Verify

```bash
kubectl get ingress

kubectl describe ingress
```

Check:

- Ingress address
- Backend service
- Service endpoints

---

# Google Ingress Migration

## Issue

Old Google annotations remained after migrating to NGINX Ingress.

Examples:

```
ingress.kubernetes.io/url-map

ingress.kubernetes.io/forwarding-rule

ingress.kubernetes.io/target-proxy
```

### Resolution

Remove obsolete annotations.

Apply updated Ingress manifest.

Verify:

```bash
kubectl describe ingress hello-gke
```

---

# Newman Functional Testing

## Issue

Functional tests failed.

### Errors

```
Invalid URI

Name or service not known

BASE_URL empty
```

### Cause

The application was exposed using a ClusterIP Service.

ClusterIP is not reachable externally.

### Resolution

Two approaches were evaluated:

- Access through Kubernetes Ingress
- Port-forward the ClusterIP Service

Development testing currently uses:

```bash
kubectl port-forward svc/hello-gke 8080:80
```

---

# GitHub Actions Cleanup

## Issue

Post-job cleanup failed.

### Error

```
action.yml not found
```

### Cause

The cleanup step deleted the GitHub Actions cache.

### Resolution

Do not delete:

```
~/actions-runner/_work/_actions
```

Only clean:

- Docker cache
- Temporary files
- Build workspace

---

# Useful Commands

## Kubernetes

```bash
kubectl get pods

kubectl get svc

kubectl get ingress

kubectl describe pod POD_NAME

kubectl logs POD_NAME
```

---

## Helm

```bash
helm list

helm upgrade

helm rollback
```

---

## Docker

```bash
docker images

docker ps

docker system prune -af
```

---

## GitHub Runner

```bash
systemctl status actions.runner.*

journalctl -u actions.runner.* -f
```

---

## Terraform

```bash
terraform init

terraform plan

terraform apply
```

---

# Lessons Learned

This project highlighted several important engineering principles.

- Automate repetitive tasks
- Validate infrastructure before deployment
- Build secure authentication mechanisms
- Fail deployments early when issues are detected
- Use automated testing
- Document troubleshooting steps
- Prefer Infrastructure as Code
- Continuously improve the deployment pipeline

---

# Key Takeaways

Troubleshooting is an essential part of Platform Engineering.

Rather than simply resolving issues, documenting their causes and solutions creates reusable operational knowledge that reduces future downtime and accelerates incident resolution.
