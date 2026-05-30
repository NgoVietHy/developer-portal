#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo ".env not found. Copy from .env.example first."
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

GITHUB_TOKEN_VALUE="${GITHUB_TOKEN:-}"

kubectl create namespace developer-portal --dry-run=client -o yaml | kubectl apply -f -

kubectl -n developer-portal create secret generic backstage-secret \
  --from-literal=GITHUB_TOKEN="${GITHUB_TOKEN_VALUE}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n developer-portal create secret generic postgres-secret \
  --from-literal=POSTGRES_DB="${POSTGRES_DB}" \
  --from-literal=POSTGRES_USER="${POSTGRES_USER}" \
  --from-literal=POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n developer-portal create configmap backstage-config \
  --from-literal=NODE_ENV=production \
  --from-literal=POSTGRES_HOST="${POSTGRES_HOST}" \
  --from-literal=POSTGRES_PORT="${POSTGRES_PORT}" \
  --from-literal=POSTGRES_DB="${POSTGRES_DB}" \
  --from-literal=BACKSTAGE_BASE_URL="${BACKSTAGE_BASE_URL}" \
  --from-literal=BACKEND_BASE_URL="${BACKEND_BASE_URL}" \
  --from-literal=K8S_CLUSTER_NAME="${K8S_CLUSTER_NAME}" \
  --from-literal=K8S_CLUSTER_URL="${K8S_CLUSTER_URL}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets and configmap applied from .env"
