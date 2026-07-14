# 07 - Observability

## Overview

In modern cloud-native environments, simply deploying applications is not enough. Engineers must continuously monitor application health, infrastructure performance, and system reliability. Observability provides deep visibility into the behavior of applications and Kubernetes clusters, allowing engineers to detect issues before users are affected.

This project implements a complete observability stack for the private GKE cluster using the **kube-prometheus-stack Helm chart**, which includes:

- Prometheus
- Alertmanager
- Grafana
- kube-state-metrics
- Node Exporter
- Prometheus Operator

The observability platform enables:

- Infrastructure monitoring
- Kubernetes monitoring
- Application monitoring
- Performance visualization
- Automated alerting through email

---

# Objectives

After completing this chapter you will understand how to:

- Deploy a production-grade monitoring stack
- Monitor Kubernetes resources
- Collect application metrics
- Visualize metrics using Grafana dashboards
- Configure Alertmanager
- Send email alerts through Gmail SMTP
- Create custom Prometheus alert rules
- Troubleshoot monitoring issues

---

# Why Observability?

Imagine your production application suddenly becomes unavailable.

Without monitoring:

- Users complain first.
- Engineers manually investigate.
- Root cause identification takes time.
- Downtime increases.

With observability:

- Prometheus detects unhealthy resources.
- Alertmanager sends an email immediately.
- Engineers investigate before customers report the issue.
- Recovery time is significantly reduced.

Observability enables proactive operations instead of reactive troubleshooting.

---

# Observability Architecture

```
                    +-------------------------+
                    |     Hello GKE App       |
                    +-----------+-------------+
                                |
                                |
                        Kubernetes Metrics
                                |
                                |
                +---------------v----------------+
                | kube-state-metrics             |
                +---------------+----------------+
                                |
                                |
                +---------------v----------------+
                |        Prometheus              |
                |  Collects & Stores Metrics     |
                +-------+--------------+---------+
                        |              |
                        |              |
                PromQL Queries     Alert Rules
                        |              |
                        |              |
                +-------v-----+   +----v---------+
                | Grafana     |   | Alertmanager |
                +-------------+   +------+-------+
                                        |
                                        |
                                  Gmail SMTP
                                        |
                                        |
                              Email Notifications
```

---

# Components Used

## Prometheus

Prometheus is responsible for collecting metrics from Kubernetes and applications.

Responsibilities:

- Scrapes metrics
- Stores time-series data
- Executes PromQL queries
- Evaluates alert rules
- Sends alerts to Alertmanager

Default Port

```
9090
```

---

## Alertmanager

Alertmanager receives alerts from Prometheus.

Responsibilities

- Groups alerts
- Removes duplicates
- Routes alerts
- Sends notifications
- Handles alert silencing

Notification Channels

- Email
- Slack
- PagerDuty
- Microsoft Teams
- Webhooks

In this project we configured:

- Gmail SMTP

Default Port

```
9093
```

---

## Grafana

Grafana visualizes Prometheus metrics through dashboards.

Capabilities

- Cluster dashboards
- Node dashboards
- Pod dashboards
- CPU usage
- Memory usage
- Network traffic
- Storage utilization

Default Port

```
3000
```

---

## kube-state-metrics

kube-state-metrics exposes Kubernetes object information as Prometheus metrics.

Examples

- Deployment replicas
- StatefulSets
- Pods
- Services
- Nodes
- Namespaces

Example metric

```
kube_deployment_status_replicas_available
```

Our custom alert:

```
HelloGKEApplicationDown
```

uses this metric.

---

## Node Exporter

Node Exporter collects operating system metrics from every Kubernetes node.

Examples

- CPU utilization
- Memory utilization
- Disk usage
- Filesystem usage
- Network statistics

---

## Prometheus Operator

The Prometheus Operator automates Prometheus management inside Kubernetes.

Instead of manually editing Prometheus configuration files, we simply create Kubernetes Custom Resources.

Examples

- ServiceMonitor
- PodMonitor
- PrometheusRule
- Alertmanager

The operator automatically updates Prometheus configuration whenever these resources change.

---

# Installing kube-prometheus-stack

The monitoring stack was installed using Helm.

## Add Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
```

---

## Create Namespace

```bash
kubectl create namespace monitoring
```

---

## Install Monitoring Stack

```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
    --namespace monitoring
```

---

## Verify Installation

```bash
helm list -n monitoring
```

Expected Output

```
NAME          NAMESPACE
monitoring    monitoring
```

---

## Verify Pods

```bash
kubectl get pods -n monitoring
```

Example

```
alertmanager-monitoring-kube-prometheus-alertmanager-0

monitoring-grafana

monitoring-kube-state-metrics

monitoring-prometheus-node-exporter

prometheus-monitoring-kube-prometheus-prometheus-0
```

All pods should eventually reach the **Running** state.

---

## Verify Services

```bash
kubectl get svc -n monitoring
```

Example

```
monitoring-grafana

monitoring-kube-prometheus-prometheus

monitoring-kube-prometheus-alertmanager
```

---

# Verifying the Installation

Check Helm release

```bash
helm list -n monitoring
```

Check StatefulSets

```bash
kubectl get statefulsets -n monitoring
```

Check Deployments

```bash
kubectl get deployments -n monitoring
```

Check Services

```bash
kubectl get svc -n monitoring
```

Check Pods

```bash
kubectl get pods -n monitoring
```

If all components are running successfully, the observability platform is ready for configuration.

---

# Summary

At this stage we have successfully:

- Installed kube-prometheus-stack
- Deployed Prometheus
- Deployed Alertmanager
- Deployed Grafana
- Deployed kube-state-metrics
- Deployed Node Exporter
- Installed Prometheus Operator
- Verified all monitoring components are running successfully

# Observability - Part 2: Prometheus Alerting and Alertmanager

## 1. Overview

Alerting is a critical component of Kubernetes observability.

Monitoring tells us:

* What is happening in the system?
* What are the current metrics?

Alerting answers:

* Is this condition important enough to notify someone?
* Should we take action?

In our GKE platform project, we implemented:

* Prometheus for metrics collection
* PrometheusRule for defining alert conditions
* Alertmanager for alert processing and notification
* Gmail SMTP integration for email notifications

The complete alerting flow:

```
Application
     |
     |
Kubernetes Metrics
     |
     |
kube-state-metrics / cAdvisor
     |
     |
Prometheus
     |
     |
PrometheusRule
     |
     |
Alertmanager
     |
     |
Email Notification
```

---

# 2. Why Alerting is Required

Without alerting:

Example:

```
Application goes down
        |
        |
Prometheus collects metrics
        |
        |
Nobody knows about the issue
```

With alerting:

```
Application goes down
        |
        |
Prometheus detects unhealthy state
        |
        |
Alert rule evaluates condition
        |
        |
Alertmanager receives alert
        |
        |
Email notification sent
```

Alerting reduces:

* Manual monitoring
* Mean Time To Detect (MTTD)
* Production downtime

---

# 3. Prometheus Alerting Components

## 3.1 PrometheusRule

PrometheusRule is a Kubernetes Custom Resource Definition (CRD).

It defines:

* Alert name
* Condition
* Duration
* Severity
* Description

Example:

```
HelloGKEApplicationDown
```

This alert checks whether our application has available replicas.

---

## 3.2 Alertmanager

Alertmanager is responsible for:

* Receiving alerts from Prometheus
* Grouping similar alerts
* Filtering unwanted alerts
* Routing alerts
* Sending notifications

Prometheus does not send emails directly.

The flow is:

```
Prometheus
     |
     |
Alertmanager
     |
     |
Email / Slack / PagerDuty
```

---

# 4. Installing Prometheus Stack

We used:

```
kube-prometheus-stack
```

This Helm chart installs:

* Prometheus
* Alertmanager
* Grafana
* Node Exporter
* kube-state-metrics
* Prometheus Operator

Verify installation:

```bash
kubectl get pods -n monitoring
```

Example output:

```
prometheus-monitoring-kube-prometheus-prometheus-0
alertmanager-monitoring-kube-prometheus-alertmanager-0
monitoring-grafana
monitoring-kube-state-metrics
```

---

# 5. Understanding Metrics Sources

Prometheus does not directly understand Kubernetes objects.

It depends on exporters.

## 5.1 kube-state-metrics

Provides Kubernetes object metrics.

Examples:

Deployment status:

```
kube_deployment_status_replicas_available
```

Pod restart count:

```
kube_pod_container_status_restarts_total
```

---

## 5.2 cAdvisor

Provides container metrics.

Examples:

CPU:

```
container_cpu_usage_seconds_total
```

Memory:

```
container_memory_working_set_bytes
```

---

# 6. Creating Custom Application Alerts

We created:

```
hello-gke-alerts
```

PrometheusRule:

Namespace:

```
monitoring
```

Command:

```bash
kubectl get prometheusrule -n monitoring
```

Output:

```
hello-gke-alerts
```

---

# 7. Finding Alert Rule Names

Command:

```bash
kubectl get prometheusrule -A \
-o jsonpath='{range .items[*]}
{"\n== "}{.metadata.namespace}{"/"}{.metadata.name}{" ==\n"}
{range .spec.groups[*].rules[*]}
{.alert}{"\n"}
{end}
{end}'
```

Output:

```
== monitoring/hello-gke-alerts ==

HelloGKEApplicationDown
HelloGKEPodRestarting
HelloGKEHighCPU
HelloGKEHighMemory
```

---

# 8. Application Down Alert

## Purpose

Detect when application has no available replicas.

Rule:

```yaml
- alert: HelloGKEApplicationDown
  expr:
    kube_deployment_status_replicas_available{
      deployment="hello-gke",
      namespace="default"
    } < 1

  for: 2m

  labels:
    severity: critical
```

---

## Explanation

Metric:

```
kube_deployment_status_replicas_available
```

Example healthy state:

```
available replicas = 1
```

No issue.

Example failure:

```
available replicas = 0
```

Alert condition:

```
0 < 1
```

Condition becomes true.

After:

```
for: 2m
```

Prometheus fires alert.

---

# 9. Testing Application Down Alert

## Step 1: Scale application down

```bash
kubectl scale deployment hello-gke \
--replicas=0 \
-n default
```

Verify:

```bash
kubectl get deployment hello-gke -n default
```

Expected:

```
READY   AVAILABLE

0/0       0
```

---

## Step 2: Verify metric

Query Prometheus:

```bash
curl -g \
'http://localhost:9090/api/v1/query?query=kube_deployment_status_replicas_available{deployment="hello-gke",namespace="default"}'
```

Expected:

```
"value": [
  timestamp,
  "0"
]
```

---

## Step 3: Verify Alert

```bash
curl -s http://localhost:9090/api/v1/alerts | jq
```

Example:

```json
{
 "alertname": "HelloGKEApplicationDown",
 "state": "pending"
}
```

After configured duration:

```
state: firing
```

---

# 10. Understanding Pending vs Firing

Prometheus alert states:

## Pending

Condition is true but waiting for "for" duration.

Example:

Rule:

```
for: 2m
```

Timeline:

```
00:00
Condition becomes true

00:01
Alert = Pending

00:02
Alert = Firing
```

---

## Firing

Alert condition has been continuously true.

Example:

```
Application replicas = 0

Alertmanager receives notification
```

---

# 11. Scaling Application Back

Restore application:

```bash
kubectl scale deployment hello-gke \
--replicas=1 \
-n default
```

Verify:

```bash
kubectl get pods -n default
```

Expected:

```
hello-gke-xxxx   Running
```

Metric:

```
kube_deployment_status_replicas_available = 1
```

Alert resolves automatically.

---

# 12. Alertmanager Configuration

Alertmanager configuration contains:

## Global SMTP settings

Example:

```yaml
smtp_smarthost: smtp.gmail.com:587

smtp_auth_username:
learndevops694@gmail.com
```

---

## Receiver

Receiver defines where alerts are sent.

Example:

```yaml
receivers:

- name: email-notifications

  email_configs:

  - to:
      learndevops694@gmail.com
```

---

# 13. Verify Alertmanager Configuration

Check Alertmanager service:

```bash
kubectl get svc -n monitoring | grep alertmanager
```

Example:

```
monitoring-kube-prometheus-alertmanager

ClusterIP

9093/TCP
```

---

Port forward:

```bash
kubectl port-forward \
svc/monitoring-kube-prometheus-alertmanager \
9093:9093 \
-n monitoring
```

---

Check status:

```bash
curl http://localhost:9093/api/v2/status
```

Verify:

* Version
* Configuration
* Receivers

---

# 14. Verify Alerts Reached Alertmanager

Command:

```bash
curl http://localhost:9093/api/v2/alerts | jq
```

Example:

```json
{
 "labels": {
   "alertname": "HelloGKEApplicationDown",
   "severity": "critical"
 }
}
```

This confirms:

```
Prometheus
    |
    |
Alertmanager
```

communication is working.

---

# 15. SMTP Email Testing

Before testing alerts, SMTP connectivity can be verified.

Using swaks:

```bash
swaks \
--to learndevops694@gmail.com \
--server smtp.gmail.com:587 \
--auth LOGIN \
--auth-user learndevops694@gmail.com \
--auth-password APP_PASSWORD
```

Successful response:

```
235 2.7.0 Accepted
```

means Gmail SMTP authentication works.

---

# 16. Troubleshooting Alerting

## Problem: Alert exists in Prometheus but no email

Check:

### 1. Is Alertmanager receiving alert?

```bash
curl http://localhost:9093/api/v2/alerts
```

If empty:

Problem is between:

```
Prometheus
     |
     |
Alertmanager
```

---

### 2. Check Prometheus Alertmanager configuration

```bash
curl http://localhost:9090/api/v1/status/config
```

Verify:

```
alertmanagers:
```

contains:

```
monitoring-kube-prometheus-alertmanager
```

---

### 3. Check Alertmanager logs

```bash
kubectl logs \
-n monitoring \
alertmanager-monitoring-kube-prometheus-alertmanager-0 \
-c alertmanager
```

---

### 4. Check SMTP errors

```bash
kubectl logs \
-n monitoring \
alertmanager-monitoring-kube-prometheus-alertmanager-0
```

Look for:

```
failed to send email
authentication failed
```

---

# 17. Current Project Validation

Completed successfully:

✅ Prometheus installed
✅ kube-state-metrics collecting Kubernetes metrics
✅ Custom PrometheusRule created
✅ Application health alert created
✅ Alert triggered during scale down
✅ Alertmanager received alert
✅ Gmail SMTP configured
✅ Email notification received successfully

---

# 18. Current Observability Architecture

```
                  User
                   |
                   |
              Gmail Inbox
                   |
                   |
            Alertmanager
                   |
                   |
             Prometheus
                   |
          ----------------
          |              |
          |              |
 kube-state-metrics   cAdvisor
          |
          |
     Kubernetes API
          |
          |
       GKE Cluster

```

---
