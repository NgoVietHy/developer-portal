#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo update >/dev/null

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values "${ROOT_DIR}/monitoring/kube-prometheus-values.yaml"

kubectl wait --for=condition=Established crd/servicemonitors.monitoring.coreos.com --timeout=180s
kubectl apply -f "${ROOT_DIR}/k8s/base/monitoring/service-monitors.yaml"

kubectl -n monitoring rollout status deployment/kube-prom-stack-grafana --timeout=600s
kubectl -n monitoring rollout status deployment/kube-prom-stack-kube-prome-operator --timeout=600s

echo "Monitoring stack is ready."
