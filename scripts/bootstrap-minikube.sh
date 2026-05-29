#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

minikube start --driver=docker --force
minikube addons enable ingress
minikube addons enable metrics-server

"${ROOT_DIR}/scripts/build-local-images.sh"
"${ROOT_DIR}/scripts/install-monitoring.sh"
GHCR_OWNER="${GHCR_OWNER:-your-org}" GHCR_REPO="${GHCR_REPO:-developer-portal}" IMAGE_TAG=latest \
  "${ROOT_DIR}/scripts/deploy-k8s.sh"

if [[ -f "${ROOT_DIR}/.env" ]]; then
  "${ROOT_DIR}/scripts/apply-secrets-from-env.sh"
  kubectl -n developer-portal rollout restart deployment/postgres
  kubectl -n developer-portal rollout restart deployment/backstage-backend
  kubectl -n developer-portal rollout status deployment/postgres --timeout=300s
  kubectl -n developer-portal rollout status deployment/backstage-backend --timeout=600s
fi

"${ROOT_DIR}/scripts/import-grafana-dashboard.sh" || true

MINIKUBE_IP="$(minikube ip)"
if grep -q "portal.local" /etc/hosts && grep -q "grafana.local" /etc/hosts; then
  echo "Hosts entries already exist."
else
  echo "Add hosts entries if missing:"
  echo "  ${MINIKUBE_IP} portal.local grafana.local"
fi

echo "Bootstrap completed."
