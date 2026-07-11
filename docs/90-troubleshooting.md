# 90 - Troubleshooting Guide

## Overview

Building a production-style CI/CD platform involves troubleshooting issues across multiple technologies including Terraform, Google Cloud, Kubernetes, Docker, GitHub Actions, networking, DNS, and TLS.

This document summarizes the major issues encountered during the project, their root causes, and the resolutions implemented.

---

# Terraform

## Issue

Terraform failed while provisioning infrastructure.

### Symptoms

- Resource creation failed
- API not enabled
- Dependency errors

### Resolution

Enable the required Google Cloud APIs before running Terraform.

```bash
terraform init

terraform plan

terraform apply
```

---

# Private GKE Cluster Access

## Issue

Unable to access the Kubernetes cluster from Cloud Shell.

### Cause

The cluster uses a private control plane.

Only resources inside the VPC can communicate with the Kubernetes API.

### Resolution

Use the Compute Engine administration VM.

```bash
gcloud compute ssh my-tf-instance

gcloud container clusters get-credentials my-tf-cluster \
--zone us-central1-a
```

---

# Java Version

## Issue

Application build failed.

### Error

```
release version 21 not supported
```

### Resolution

Configure the project to use Java 17.

Verify:

```bash
java -version

javac -version
```

---

# Artifact Registry Authentication

## Issue

Docker image push failed.

### Cause

Docker was not authenticated with Artifact Registry.

### Resolution

```bash
gcloud auth configure-docker us-central1-docker.pkg.dev
```

---

# Artifact Registry Permissions

## Issue

Image upload failed.

### Error

```
artifactregistry.repositories.uploadArtifacts denied
```

### Cause

Missing IAM permissions.

### Resolution

Grant the following IAM role:

```
Artifact Registry Writer
```

---

# Workload Identity Federation

## Issue

GitHub Actions authentication failed.

### Errors

- Unauthorized
- Permission denied
- Invalid principalSet

### Resolution

Verified:

- Workload Identity Pool
- Provider
- Attribute Mapping
- IAM bindings
- Service Account permissions
- Repository restrictions

---

# GitHub Self-Hosted Runner

## Issue

Runner stopped after VM reboot.

### Cause

Runner was started manually.

### Resolution

Configure the runner as a systemd service.

```bash
systemctl status actions.runner.*
```

---

# Trivy Image Scan

## Issue

Pipeline failed during vulnerability scanning.

### Cause

Critical or High severity vulnerabilities detected.

### Resolution

Updated:

- Spring Boot dependencies
- Tomcat version
- Jackson libraries
- Docker base image

Rebuilt the container image and reran the pipeline.

---

# Helm Deployment

## Issue

Deployment completed but the new application version was not visible.

### Cause

Old image tag was still being referenced.

### Resolution

Verify:

```bash
helm list

helm get values hello-gke
```

Confirm that Helm receives the updated image tag from GitHub Actions.

---

# Kubernetes Deployment

## Issue

Deployment rollout failed.

### Resolution

Verify rollout:

```bash
kubectl rollout status deployment/hello-gke
```

Inspect resources:

```bash
kubectl get pods

kubectl describe pod POD_NAME

kubectl logs POD_NAME
```

---

# Service Connectivity

## Issue

Application was unreachable.

### Resolution

Verify:

```bash
kubectl get svc

kubectl get endpoints
```

Confirm:

- Service selectors
- Pod labels
- Healthy endpoints

---

# NGINX Ingress Migration

## Issue

Application remained associated with the old Google Ingress configuration.

### Cause

Google-specific annotations were still present.

Examples:

```
ingress.kubernetes.io/url-map

ingress.kubernetes.io/target-proxy

ingress.kubernetes.io/forwarding-rule
```

### Resolution

Remove the old annotations.

Redeploy the Ingress using:

```yaml
ingressClassName: nginx
```

---

# cert-manager

## Issue

TLS certificate was not issued.

### Checks

```bash
kubectl get certificate

kubectl get certificaterequest

kubectl get challenge

kubectl get order
```

### Resolution

Verified:

- DNS record
- ClusterIssuer
- Ingress annotations
- HTTP-01 challenge

Certificate was issued successfully.

---

# Custom Domain

## Issue

Custom domain did not resolve correctly.

### Resolution

Verified:

```bash
dig app.devopswithsachin.in

nslookup app.devopswithsachin.in
```

Confirmed DNS A record points to the NGINX Ingress external IP.

---

# HTTPS / TLS

## Issue

HTTPS worked from Linux VM but failed from the corporate Windows laptop.

### Symptoms

```
Recv failure: Connection was reset
```

Linux:

```
HTTP/2 200
```

Windows:

```
TLS handshake failed
```

### Investigation

Verified:

- DNS
- Certificate
- cert-manager
- Let's Encrypt
- NGINX Ingress
- TLS versions
- Firewall
- Global Protect
- Windows Defender

### Root Cause

Corporate security policy was intercepting and blocking the TLS connection.

The application functioned correctly from external systems.

---

# Functional Testing

## Issue

Newman tests initially failed.

### Cause

The application was only exposed through a ClusterIP Service.

### Resolution

Migrated to:

- NGINX Ingress
- Custom domain
- HTTPS

Functional tests now execute against:

```
https://app.devopswithsachin.in
```

---

# GitHub Actions Cleanup

## Issue

Post-job cleanup failed.

### Cause

Workflow deleted the GitHub Actions cache.

### Resolution

Do not remove:

```
~/actions-runner/_work/_actions
```

Clean only:

- Docker cache
- Temporary files
- Build artifacts

---

# Useful Commands

## Kubernetes

```bash
kubectl get pods

kubectl get svc

kubectl get ingress

kubectl get certificates

kubectl get certificaterequests

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

Throughout this project, several important engineering principles became clear:

- Validate infrastructure before deployment.
- Automate repetitive tasks.
- Prefer short-lived credentials over static keys.
- Fail deployments early when quality checks fail.
- Test applications after deployment, not just before.
- Secure applications using HTTPS by default.
- Document every issue and its resolution.
- Build reusable operational knowledge.

---

# Key Takeaways

Troubleshooting is a critical skill for Platform Engineers.

Building this platform required investigating issues across infrastructure, Kubernetes, networking, authentication, CI/CD, DNS, and TLS.

Documenting these problems and their solutions creates valuable operational knowledge, reduces future troubleshooting time, and demonstrates practical experience with production-style cloud platforms.
