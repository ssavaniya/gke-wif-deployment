# Helm Package Manager

## Objective

Learn how Helm simplifies Kubernetes application deployment and automate deployments through the GitHub Actions pipeline.

---

# What is Helm?

Helm is the package manager for Kubernetes.

Instead of managing multiple Kubernetes YAML files manually, Helm packages them into a reusable **Helm Chart**.

A Helm Chart can contain:

- Deployment
- Service
- Ingress
- ConfigMap
- Secret
- Horizontal Pod Autoscaler
- Network Policies

Helm makes deployments easier, repeatable, and easier to maintain.

---

# Why We Used Helm

Initially, our application could be deployed using plain Kubernetes YAML files.

However, every deployment required updating:

- Docker image tag
- Replica count
- Configuration values

Helm solves this by storing all Kubernetes resources inside one chart and updating only the required values during deployment.

---

# Helm Chart Structure

```
helm/
└── hello-gke/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        ├── service.yaml
        ├── ingress.yaml
        └── hpa.yaml
```

---

# Files Used

## Chart.yaml

Contains chart metadata.

Example:

```yaml
apiVersion: v2
name: hello-gke
version: 0.1.0
```

---

## values.yaml

Stores configurable values.

Example:

```yaml
replicaCount: 1

image:
  repository: us-central1-docker.pkg.dev/proserv-task02/springboot-repo/hello-gke
  tag: latest

service:
  port: 80
```

Instead of changing Kubernetes YAML files, we only update values.

---

## templates/

Contains Kubernetes manifests with Helm variables.

Example:

```yaml
image:
  {{ .Values.image.repository }}:{{ .Values.image.tag }}
```

During deployment Helm replaces these values automatically.

---

# How We Implemented Helm

### Step 1

Created a Helm Chart.

```
helm create hello-gke
```

---

### Step 2

Removed unnecessary default files.

Kept only:

- deployment.yaml
- service.yaml
- ingress.yaml
- hpa.yaml

---

### Step 3

Updated deployment template to use Helm values.

Example:

```yaml
image:
  "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

---

### Step 4

Configured values.yaml

Added:

- Docker repository
- Image tag
- Replica count
- Service port
- Resources

---

### Step 5

Installed the application

```
helm install hello-gke ./helm/hello-gke
```

---

### Step 6

Verified deployment

```
helm list

kubectl get pods

kubectl get svc
```

Application deployed successfully.

---

# Automating Deployment

Instead of deploying manually, GitHub Actions now performs:

1. Build Docker image
2. Scan image using Trivy
3. Push image to Artifact Registry
4. Deploy using Helm

Deployment command:

```bash
helm upgrade --install hello-gke ./helm/hello-gke \
--set image.repository=${IMAGE_URI} \
--set image.tag=${GITHUB_SHA}
```

Only the Docker image changes.

Helm updates the Deployment automatically.

---

# Verification

Check Helm release

```bash
helm list
```

Check deployment

```bash
kubectl get deployment
```

Check pods

```bash
kubectl get pods
```

Check service

```bash
kubectl get svc
```

Check ingress

```bash
kubectl get ingress
```

---

# Useful Helm Commands

Install application

```bash
helm install hello-gke ./helm/hello-gke
```

Upgrade application

```bash
helm upgrade hello-gke ./helm/hello-gke
```

Upgrade or install

```bash
helm upgrade --install hello-gke ./helm/hello-gke
```

List releases

```bash
helm list
```

Check release status

```bash
helm status hello-gke
```

View release history

```bash
helm history hello-gke
```

Rollback

```bash
helm rollback hello-gke <revision>
```

Validate chart

```bash
helm lint ./helm/hello-gke
```

Render templates

```bash
helm template hello-gke ./helm/hello-gke
```

---

# How to Explain Helm

Helm is a package manager for Kubernetes.

Instead of maintaining many Kubernetes YAML files manually, we package everything into a Helm Chart.

During deployment, GitHub Actions only updates the Docker image tag and Helm upgrades the application.

This makes deployments:

- Faster
- Repeatable
- Easier to manage
- Easier to rollback

---

# What I Learned

- What Helm is
- Helm Chart structure
- values.yaml
- Template variables
- Installing applications
- Upgrading applications
- GitHub Actions integration
- Rollback capability
- Managing Kubernetes deployments using Helm

---

# Key Takeaway

Helm simplified Kubernetes deployments by packaging all application resources into a reusable chart.

Our deployment flow became:

```
Developer
      │
      ▼
GitHub Actions
      │
      ▼
Build Docker Image
      │
      ▼
Trivy Scan
      │
      ▼
Push to Artifact Registry
      │
      ▼
Helm Upgrade
      │
      ▼
Google Kubernetes Engine
      │
      ▼
Running Application
```
