# Ingress Comparison

## Overview

One of the objectives of this project was to understand how different Kubernetes Ingress implementations work.

Initially, the application was exposed using the default Google Kubernetes Engine (GKE) Ingress Controller.

Later, the project was migrated to the NGINX Ingress Controller to better understand third-party ingress solutions commonly used in enterprise Kubernetes environments.

This document compares both implementations and explains why NGINX Ingress was ultimately selected.

---

# What is Ingress?

An Ingress is a Kubernetes resource that manages external HTTP and HTTPS traffic into a cluster.

Instead of exposing every application using a dedicated LoadBalancer Service, a single Ingress Controller can route requests to multiple services.

General architecture:

```text
Internet

↓

Ingress Controller

↓

Service

↓

Pods
```

---

# Why Use Ingress?

Without Ingress:

```text
Internet

↓

LoadBalancer Service

↓

Application
```

Every application requires:

- Public IP
- Load Balancer
- Additional cost

With Ingress:

```text
Internet

↓

Ingress

↓

Multiple Services

↓

Applications
```

Advantages:

- Single entry point
- Path-based routing
- Host-based routing
- SSL termination
- Lower infrastructure cost

---

# Google GKE Ingress

The project initially used Google's managed Ingress Controller.

Characteristics:

- Managed by Google Cloud
- Automatically provisions Cloud Load Balancer
- Integrates with Cloud Armor
- Supports Google-managed SSL certificates
- Uses Google networking infrastructure

Application flow:

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

Example:

```
ADDRESS

136.xxx.xxx.xxx
```

---

# Google Ingress Annotations

Google automatically added several annotations to the Ingress resource.

Examples:

```
ingress.kubernetes.io/url-map

ingress.kubernetes.io/target-proxy

ingress.kubernetes.io/forwarding-rule
```

These annotations reference Google Cloud Load Balancer resources created automatically by the GKE Ingress Controller.

After migrating away from Google Ingress, these annotations were removed because they were no longer required.

---

# NGINX Ingress Controller

To better understand enterprise Kubernetes networking, the project introduced the NGINX Ingress Controller.

Installation:

```bash
kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

Verification:

```bash
kubectl get pods -n ingress-nginx

kubectl get svc -n ingress-nginx

kubectl get ingressclass
```

Example:

```
IngressClass

nginx
```

---

# NGINX Ingress Architecture

```text
Internet

↓

NGINX LoadBalancer

↓

NGINX Ingress Controller

↓

ClusterIP Service

↓

Pods
```

Unlike Google's managed controller, NGINX runs inside Kubernetes as Pods.

---

# Migrating the Application

The application Ingress manifest was updated.

Previous configuration:

```
No IngressClass
```

Updated configuration:

```yaml
ingressClassName: nginx
```

The Ingress resource now uses the NGINX controller instead of the Google-managed controller.

Verification:

```bash
kubectl describe ingress hello-gke
```

Example:

```
Ingress Class

nginx
```

---

# URL Rewriting

NGINX supports request rewriting using annotations.

Example:

```yaml
nginx.ingress.kubernetes.io/rewrite-target: /
```

This allows incoming requests to be rewritten before reaching the backend service.

---

# Removing Google-Specific Configuration

After migration, the following annotations were removed:

```
ingress.kubernetes.io/url-map

ingress.kubernetes.io/forwarding-rule

ingress.kubernetes.io/target-proxy
```

These annotations are specific to Google's Ingress Controller and are not used by NGINX.

The final Ingress configuration only contains application-specific annotations.

---

# Comparison

| Feature | Google GKE Ingress | NGINX Ingress |
|----------|--------------------|---------------|
| Managed by | Google Cloud | Kubernetes |
| Runs Inside Cluster | No | Yes |
| Cloud Load Balancer | Automatic | Uses LoadBalancer Service |
| SSL Support | Google Managed Certificates | cert-manager / TLS Secrets |
| Path Routing | Yes | Yes |
| Host Routing | Yes | Yes |
| Custom Configuration | Limited | Extensive |
| Enterprise Adoption | High | Very High |

---

# Advantages of Google Ingress

- Fully managed
- Deep Google Cloud integration
- Easy SSL configuration
- Cloud Armor integration
- Minimal operational overhead

---

# Advantages of NGINX Ingress

- Vendor independent
- Highly configurable
- Supports advanced routing
- Widely adopted
- Large community
- Consistent across cloud providers

---

# Current Implementation

The project now uses:

```text
Internet

↓

NGINX Ingress Controller

↓

ClusterIP Service

↓

Spring Boot Application
```

The previous Google-specific annotations have been removed.

Traffic is routed entirely through the NGINX Ingress Controller.

---

# Future Enhancements

Planned improvements include:

- HTTPS with TLS
- cert-manager integration
- Automatic certificate renewal
- Rate limiting
- Authentication
- Canary deployments
- Web Application Firewall
- Custom domains

---

# Key Takeaways

Both Google GKE Ingress and NGINX Ingress provide reliable methods for exposing Kubernetes applications.

Google Ingress offers a fully managed experience tightly integrated with Google Cloud, while NGINX provides greater flexibility, portability, and advanced configuration options.

By implementing both approaches, this project demonstrates an understanding of managed cloud networking as well as enterprise Kubernetes networking patterns commonly used across multiple cloud providers.
