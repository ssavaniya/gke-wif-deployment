# 10. Kubernetes Horizontal Pod Autoscaler (HPA)

## Objective

Learn how Kubernetes automatically scales application Pods based on CPU utilization.

---

# What is Horizontal Pod Autoscaler (HPA)?

Horizontal Pod Autoscaler (HPA) is a Kubernetes feature that automatically increases or decreases the number of Pods running an application based on resource utilization such as CPU or Memory.

Instead of manually increasing replicas during high traffic, Kubernetes continuously monitors the application's resource usage and adjusts the number of Pods automatically.

---

# Why do we need HPA?

Without HPA:

- Fixed number of Pods
- Application performance may degrade during heavy traffic
- Manual scaling is required
- Resources may be wasted during low traffic

With HPA:

- Automatically scales application Pods
- Handles increased traffic
- Improves application availability
- Optimizes resource utilization
- Reduces manual effort

---

# How HPA Works

```
                 Users
                   │
                   ▼
          Spring Boot Application
                   │
                   ▼
           CPU / Memory Usage
                   │
                   ▼
             Metrics Server
                   │
                   ▼
    Horizontal Pod Autoscaler (HPA)
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
 Increase Replicas     Decrease Replicas
```

The HPA continuously monitors application resource utilization.

If the utilization exceeds the configured threshold, Kubernetes automatically creates additional Pods.

When the utilization decreases, Kubernetes removes unnecessary Pods.

---

# Prerequisites

Before implementing HPA, the following components must already exist:

- Kubernetes Cluster
- Metrics Server
- Application Deployment
- CPU Requests configured on the Deployment

---

# HPA Configuration

The following HPA resource was created:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler

metadata:
  name: hello-gke

spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hello-gke

  minReplicas: 1
  maxReplicas: 5

  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 10
```

> **Note:** CPU utilization was intentionally set to **10%** for demonstration purposes so scaling could be observed quickly.

---

# Deployment Resource Configuration

To allow HPA to calculate CPU utilization, CPU Requests and Limits were added to the Deployment.

```yaml
resources:
  requests:
    cpu: 100m
    memory: 256Mi

  limits:
    cpu: 500m
    memory: 512Mi
```

CPU Requests are mandatory because HPA calculates utilization using the configured CPU request.

Without CPU Requests, HPA shows:

```
cpu: <unknown>
```

---

# Verification Commands

Verify HPA

```bash
kubectl get hpa
```

Verify Deployment

```bash
kubectl describe deployment hello-gke
```

Check Pod Resource Usage

```bash
kubectl top pods
```

Watch HPA

```bash
watch kubectl get hpa
```

Watch Pods

```bash
watch kubectl get pods
```

---

# Load Testing

A simple load generator Pod was created to continuously send HTTP requests to the application.

This generated CPU load, allowing HPA to trigger automatic scaling.

---

# Demo Results

### Initial State

```
Replicas: 1
```

### During Load Test

```
CPU Utilization: 113%
Target CPU: 10%

Desired Replicas: 5
```

Current Pod Status

```
Running Pods : 2

Pending Pods : 3
```

The Pending Pods occurred because the GKE cluster did not have enough available resources to schedule all requested Pods.

This confirmed that HPA was functioning correctly and requesting additional replicas.

---

# Key Learnings

During this implementation, the following concepts were learned:

- Kubernetes Horizontal Pod Autoscaler (HPA)
- Metrics Server integration
- CPU-based automatic scaling
- Importance of CPU Requests
- Dynamic Pod scaling
- Resource utilization monitoring

---

# Commands Used

Create HPA

```bash
kubectl apply -f hpa.yaml
```

View HPA

```bash
kubectl get hpa
```

Describe HPA

```bash
kubectl describe hpa hello-gke
```

Generate Load

```bash
kubectl apply -f load-generator.yaml
```

Watch Scaling

```bash
watch kubectl get pods
```

Watch HPA

```bash
watch kubectl get hpa
```

---

# Summary

Successfully implemented Kubernetes Horizontal Pod Autoscaler (HPA) for the sample Spring Boot application.

Verified:

- Automatic Pod Scaling
- CPU-based scaling
- Metrics Server integration
- Dynamic replica creation
- End-to-end HPA workflow

This implementation demonstrated how Kubernetes automatically scales applications based on CPU utilization without manual intervention.

---
