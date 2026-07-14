#!/bin/bash

set -e

echo "======================================="
echo "Installing kube-prometheus-stack"
echo "======================================="

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true

helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Installing / Upgrading kube-prometheus-stack..."

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values platform/monitoring/values.yaml

echo ""
echo "Verifying Helm release..."

helm status monitoring -n monitoring

echo ""
echo "Waiting for kube-state-metrics..."

kubectl rollout status deployment/monitoring-kube-state-metrics \
  -n monitoring \
  --timeout=300s

echo ""
echo "Waiting for Grafana..."

kubectl rollout status deployment/monitoring-grafana \
  -n monitoring \
  --timeout=300s

echo ""
echo "Waiting for Prometheus Operator..."

kubectl rollout status deployment/monitoring-kube-prometheus-operator \
  -n monitoring \
  --timeout=300s

echo ""
echo "Waiting for Prometheus..."

kubectl rollout status statefulset/prometheus-monitoring-kube-prometheus-prometheus \
  -n monitoring \
  --timeout=300s

echo ""
echo "Waiting for Alertmanager..."

kubectl rollout status statefulset/alertmanager-monitoring-kube-prometheus-alertmanager \
  -n monitoring \
  --timeout=300s

echo ""
echo "Applying Grafana Ingress..."

kubectl apply -f platform/monitoring/grafana-ingress.yaml

echo ""
echo "Applying Prometheus Rules..."

kubectl apply -f platform/monitoring/rules/

echo ""
echo "Verifying Monitoring Resources..."

kubectl get pods -n monitoring
kubectl get servicemonitor -n monitoring
kubectl get prometheusrule -n monitoring
kubectl get ingress -n monitoring

echo ""
echo "======================================="
echo "Monitoring installation completed!"
echo "======================================="
