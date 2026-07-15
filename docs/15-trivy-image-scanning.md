# 15. Docker Image Scanning using Trivy

## Overview

Trivy is an open-source vulnerability scanner used to scan Docker images for known security vulnerabilities.

In this project, Trivy is integrated into the GitHub Actions pipeline to scan the Docker image before it is pushed to Google Artifact Registry and deployed to Kubernetes.

---

# Why do we use Trivy?

- Detect security vulnerabilities in Docker images.
- Prevent vulnerable images from reaching production.
- Improve application security.
- Automate security checks in the CI/CD pipeline.

---

# How does it work?

```text
Developer
      │
      ▼
Build Docker Image
      │
      ▼
Trivy Scans Image
      │
      ▼
High/Critical Vulnerabilities?
      │
 ┌────┴────┐
 │         │
No        Yes
 │         │
 ▼         ▼
Push      Pipeline Fails
Image
```

---

# Implementation Steps

## Step 1 – Verify Trivy Installation

Before scanning images, verify that Trivy is installed on the GitHub Runner.

### Command

```bash
trivy --version
```

### Verify

Expected output:

```text
Version: 0.xx.x
```

---

## Step 2 – Cache Trivy Vulnerability Database

Downloading the vulnerability database every pipeline run increases execution time.

GitHub Actions cache is used to store the database between runs.

### GitHub Action

```yaml
- name: Cache Trivy Database
  uses: actions/cache@v4
```

### Verify

Pipeline logs should display:

```text
Cache restored successfully
```

or

```text
Cache saved successfully
```

---

## Step 3 – Scan Docker Image

Once the Docker image is built, scan it for vulnerabilities.

### Command

```bash
trivy image hello-gke:latest
```

### Verify

Expected output:

```text
Total: XX

LOW:
MEDIUM:
HIGH:
CRITICAL:
```

---

## Step 4 – Generate SARIF Report

Generate a SARIF report so GitHub Security can display scan results.

### Command

```bash
trivy image \
  --format sarif \
  --output trivy-results.sarif \
  hello-gke:latest
```

### Verify

Check that the report is generated.

```bash
ls
```

Expected:

```text
trivy-results.sarif
```

---

## Step 5 – Upload SARIF Report

Upload the SARIF report to GitHub Security.

### GitHub Action

```yaml
- name: Upload SARIF Report
  uses: github/codeql-action/upload-sarif@v4
  with:
    sarif_file: trivy-results.sarif
```

### Verify

Navigate to:

GitHub Repository

→ Security

→ Code Scanning Alerts

You should see Trivy scan results.

---

## Step 6 – Generate JSON Report

Generate a JSON report for future analysis.

### Command

```bash
trivy image \
  --format json \
  --output trivy-report.json \
  hello-gke:latest
```

### Verify

```bash
ls
```

Expected:

```text
trivy-report.json
```

---

## Step 7 – Upload JSON Report

Upload the JSON report as a GitHub Artifact.

### GitHub Action

```yaml
- name: Upload Trivy Report
  uses: actions/upload-artifact@v4
  with:
    name: trivy-report
    path: trivy-report.json
```

### Verify

Navigate to:

GitHub Repository

→ Actions

→ Workflow Run

→ Artifacts

You should see:

```text
trivy-report
```

---

## Step 8 – Enforce Security Policy

Block deployment if High or Critical vulnerabilities are found.

### Command

```bash
trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --exit-code 1 \
  hello-gke:latest
```

### Verify

**Scenario 1**

No High or Critical vulnerabilities found.

Result:

Pipeline continues successfully.

---

**Scenario 2**

High or Critical vulnerabilities found.

Result:

```text
Process completed with exit code 1
```

Deployment is stopped.

---

## Step 9 – Push Docker Image

Only after the security scan passes, push the Docker image to Google Artifact Registry.

### Command

```bash
docker push us-central1-docker.pkg.dev/proserv-task02/springboot-repo/hello-gke:<tag>
```

### Verify

```bash
gcloud artifacts docker images list \
us-central1-docker.pkg.dev/proserv-task02/springboot-repo
```

Or navigate to:

Google Cloud Console

→ Artifact Registry

→ springboot-repo

The new image should be available.

---

# Commands Used

```bash
trivy --version

trivy image hello-gke:latest

trivy image \
  --format sarif \
  --output trivy-results.sarif \
  hello-gke:latest

trivy image \
  --format json \
  --output trivy-report.json \
  hello-gke:latest

trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --exit-code 1 \
  hello-gke:latest

docker push us-central1-docker.pkg.dev/proserv-task02/springboot-repo/hello-gke:<tag>
```

---

# Outcome

- Successfully integrated Trivy into the CI/CD pipeline.
- Docker images are automatically scanned during every deployment.
- Security reports are generated and uploaded to GitHub.
- The pipeline blocks deployments when High or Critical vulnerabilities are detected.
- Only secure Docker images are deployed to the Kubernetes cluster.

---

# Key Learning

- Learned why Docker image scanning is important.
- Understood how Trivy detects vulnerabilities.
- Integrated automated security scanning into GitHub Actions.
- Learned how to generate SARIF and JSON reports.
- Understood how security gates improve application security by preventing insecure deployments.
