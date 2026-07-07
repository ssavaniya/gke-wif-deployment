i# End-to-End GitOps CI/CD Platform on Google Kubernetes Engine (GKE)

## Project Overview

This project demonstrates how to build a production-style Kubernetes platform on Google Cloud Platform using Infrastructure as Code (Terraform), GitHub Actions, Google Workload Identity Federation, Artifact Registry, Helm, and Google Kubernetes Engine (GKE).

The primary objective is to automate the complete software delivery lifecycle—from infrastructure provisioning to secure application deployment—without relying on long-lived service account keys or manual deployment steps.

The project has been built incrementally to simulate how modern Platform Engineering and DevOps teams deploy cloud-native applications in enterprise environments.

---

## Project Objectives

The project focuses on implementing a secure and production-oriented deployment pipeline capable of:

- Provisioning cloud infrastructure using Terraform
- Deploying a private GKE cluster
- Building Spring Boot applications
- Containerizing applications using Docker
- Publishing images to Artifact Registry
- Performing automated container vulnerability scanning
- Enforcing security gates before deployment
- Deploying applications using Helm
- Exposing workloads using Kubernetes Ingress
- Authenticating GitHub Actions using Workload Identity Federation
- Performing automated unit and functional testing
- Building a reusable CI/CD pipeline following GitOps principles

---

## Technologies Used

| Category | Technology |
|-----------|------------|
| Cloud | Google Cloud Platform (GCP) |
| Infrastructure | Terraform |
| Container Platform | Google Kubernetes Engine (GKE) |
| Container Runtime | Docker |
| Container Registry | Artifact Registry |
| CI/CD | GitHub Actions |
| Authentication | Workload Identity Federation (OIDC) |
| Deployment | Helm |
| Networking | Kubernetes Ingress, NGINX Ingress Controller |
| Programming | Java 17, Spring Boot |
| Build Tool | Maven |
| Security | Artifact Analysis |
| Testing | JUnit, Newman |
| Source Control | Git, GitHub |

---

## High-Level Architecture

```mermaid
flowchart LR

Developer --> GitHub

GitHub --> GitHubActionis

GitHubActions --> Build

Build --> ArtifactRegistry

ArtifactRegistry --> SecurityScan

SecurityScan --> Helm

Helm --> GKE

GKE --> Ingress

Ingress --> Application
