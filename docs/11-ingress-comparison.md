# 11 - Ingress Comparison

## Overview

One of the primary learning objectives of this project was to understand how Kubernetes applications are exposed to external users using different Ingress implementations.

The application was initially deployed using the default Google Kubernetes Engine (GKE) Ingress Controller. After understanding Google's managed solution, the project was migrated to the NGINX Ingress Controller to gain hands-on experience with the Ingress solution most commonly used in enterprise Kubernetes environments.

The final implementation uses:

- NGINX Ingress Controller
- cert-manager
- Let's Encrypt
- Custom domain
- Automatic TLS certificate renewal
- HTTPS

This document compares both approaches and explains why NGINX Ingress was selected for the final platform.

---

# What is an Ingress?

An Ingress is a Kubernetes resource that manages external HTTP and HTTPS traffic entering a Kubernetes cluster.

Instead of exposing every application through its own LoadBalancer Service, a single Ingress Controller can route requests to multiple backend services.

General architecture:

```text
Internet

↓

Ingress Controller

↓

ClusterIP Service

↓

Pods
```

---

# Why Use an Ingress?

Without an Ingress Controller:

```text
Internet

↓

LoadBalancer Service

↓

Application
```

Each application requires:

- Dedicated public IP
- Dedicated Load Balancer
- Higher infrastructure cost

With an Ingress Controller:

```text
Internet

↓

Ingress Controller

↓

Multiple Services

↓

Applications
```

Benefits include:

- Single entry point
- Host-based routing
- Path-based routing
- TLS termination
- Lower infrastructure cost
- Easier application management

---

# Google GKE Ingress

The project initially used Google's managed GKE Ingress Controller.

Characteristics:

- Fully managed by Google Cloud
- Automatically provisions a Google Cloud Load Balancer
- Integrates with Google networking
- Supports Google-managed SSL certificates
- Supports Cloud Armor
- Minimal operational overhead

Traffic flow:

```text
Internet

↓

Google Cloud Load Balancer

↓

ClusterIP Service

↓

Pods
```

Verification:

```bash
kubectl get ingress
```

---

# Google Ingress Annotations

Google automatically created several annotations.

Examples:

```
ingress.kubernetes.io/url-map

ingress.kubernetes.io/target-proxy

ingress.kubernetes.io/forwarding-rule
```

These annotations reference Google Cloud Load Balancer resources that are automatically provisioned by the managed GKE Ingress Controller.

---

# Why Migrate to NGINX?

Although Google's Ingress is easy to use, most enterprise Kubernetes environments use NGINX Ingress because it provides:

- Cloud independence
- Greater flexibility
- Rich configuration options
- Large community support
- Consistent behavior across multiple cloud providers

Migrating to NGINX also provided practical experience with Kubernetes-native networking.

---

# NGINX Ingress Controller

The project now uses the NGINX Ingress Controller running inside the Kubernetes cluster.

Verification:

```bash
kubectl get pods -n ingress-nginx
```

```bash
kubectl get svc -n ingress-nginx
```

```bash
kubectl get ingressclass
```

Expected output:

```
nginx
```

Unlike Google's managed solution, NGINX operates as Kubernetes Pods and is managed like any other workload.

---

# NGINX Architecture

```text
Internet

↓

External LoadBalancer

↓

NGINX Ingress Controller

↓

ClusterIP Service

↓

Spring Boot Pods
```

---

# Application Migration

The application Ingress resource was updated to use the NGINX controller.

Previous configuration:

```yaml
No ingressClassName
```

Updated configuration:

```yaml
ingressClassName: nginx
```

Verification:

```bash
kubectl describe ingress hello-gke
```

Expected output:

```
Ingress Class: nginx
```

---

# HTTPS with cert-manager

The NGINX Ingress Controller is integrated with cert-manager.

cert-manager automatically:

- Requests certificates from Let's Encrypt
- Stores certificates as Kubernetes TLS Secrets
- Renews certificates before expiration

The Ingress references the TLS Secret created by cert-manager.

Example:

```yaml
tls:
  - hosts:
      - app.devopswithsachin.in
    secretName: hello-gke-tls
```

---

# Custom Domain

The application is now accessible using a custom domain.

```
https://app.devopswithsachin.in
```

DNS points the domain to the external IP address of the NGINX Ingress Controller.

This provides a production-style user experience instead of relying on temporary testing domains such as sslip.io.

---

# Automatic TLS Certificate Renewal

Let's Encrypt certificates are automatically renewed by cert-manager before they expire.

Benefits include:

- No manual certificate management
- Continuous HTTPS availability
- Trusted public certificates
- Reduced operational overhead

---

# Comparison

| Feature | Google GKE Ingress | NGINX Ingress |
|----------|--------------------|---------------|
| Managed by | Google Cloud | Kubernetes |
| Runs Inside Cluster | No | Yes |
| Cloud Load Balancer | Automatically created | LoadBalancer Service |
| HTTPS | Google Managed Certificates | cert-manager + Let's Encrypt |
| Automatic Certificate Renewal | Yes | Yes |
| Host-based Routing | Yes | Yes |
| Path-based Routing | Yes | Yes |
| Custom Configuration | Limited | Extensive |
| Cloud Independent | No | Yes |
| Enterprise Adoption | High | Very High |

---

# Advantages of Google GKE Ingress

- Fully managed
- Native Google Cloud integration
- Automatic Cloud Load Balancer
- Cloud Armor support
- Minimal administration

---

# Advantages of NGINX Ingress

- Cloud agnostic
- Kubernetes native
- Highly configurable
- Supports advanced routing
- Large open-source community
- Works consistently across cloud providers
- Integrates easily with cert-manager

---

# Current Implementation

The final project uses the following request flow:

```text
User

↓

https://app.devopswithsachin.in

↓

NGINX Ingress Controller

↓

ClusterIP Service

↓

Spring Boot Pods
```

Application traffic is encrypted using HTTPS and secured with a Let's Encrypt certificate managed automatically by cert-manager.

---

# Best Practices Implemented

This project follows several Ingress best practices:

- Dedicated Ingress Controller
- Host-based routing
- HTTPS enabled
- Custom domain
- Automatic certificate renewal
- Kubernetes TLS Secrets
- ClusterIP backend services
- Infrastructure independent configuration

---

# Key Takeaways

Both Google GKE Ingress and the NGINX Ingress Controller provide reliable methods for exposing Kubernetes applications.

Google GKE Ingress offers a fully managed experience tightly integrated with Google Cloud, while NGINX Ingress provides greater flexibility, portability, and advanced configuration options.

By implementing both approaches and successfully migrating to NGINX with HTTPS, cert-manager, and a custom domain, this project demonstrates practical experience with production-style Kubernetes networking commonly used in enterprise environments.
