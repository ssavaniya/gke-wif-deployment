#!/bin/bash

set -e

echo "======================================="
echo "Installing kube-prometheus-stack"
echo "======================================="

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "Installing Helm chart..."

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --values platform/monitoring/values.yaml

echo ""
echo "Waiting for Prometheus..."

kubectl rollout status deployment/monitoring-kube-state-metrics -n monitoring

echo ""
echo "Waiting for Grafana..."

kubectl rollout status deployment/monitoring-grafana -n monitoring

echo ""
echo "Waiting for Operator..."

kubectl rollout status deployment/monitoring-kube-prometheus-operator -n monitoring

echo ""
echo "Applying Alertmanager configuration..."

kubectl apply -f platform/monitoring/alertmanager.yaml

echo ""
echo "Applying Grafana Ingress..."

kubectl apply -f platform/monitoring/grafana-ingress.yaml

echo ""
echo "Applying Prometheus Rules..."

kubectl apply -f platform/monitoring/rules/

echo ""
echo "======================================="
echo "Monitoring installation completed!"
echo "======================================="
