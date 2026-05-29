#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="developer-portal"
OWNER="${GHCR_OWNER:?GHCR_OWNER is required}"
REPO="${GHCR_REPO:-developer-portal}"
TAG="${IMAGE_TAG:?IMAGE_TAG is required}"

kubectl apply -k "${ROOT_DIR}/k8s/overlays/minikube"

kubectl -n "${NAMESPACE}" set image deployment/backstage-backend backstage-backend="ghcr.io/${OWNER}/${REPO}/backstage-backend:${TAG}"
kubectl -n "${NAMESPACE}" set image deployment/backstage-frontend backstage-frontend="ghcr.io/${OWNER}/${REPO}/backstage-frontend:${TAG}"
kubectl -n "${NAMESPACE}" set image deployment/service-catalog service-catalog="ghcr.io/${OWNER}/${REPO}/service-catalog:${TAG}"
kubectl -n "${NAMESPACE}" set image deployment/service-identity service-identity="ghcr.io/${OWNER}/${REPO}/service-identity:${TAG}"

kubectl -n "${NAMESPACE}" rollout status deployment/postgres --timeout=300s
kubectl -n "${NAMESPACE}" rollout status deployment/backstage-backend --timeout=600s
kubectl -n "${NAMESPACE}" rollout status deployment/backstage-frontend --timeout=600s
kubectl -n "${NAMESPACE}" rollout status deployment/service-catalog --timeout=300s
kubectl -n "${NAMESPACE}" rollout status deployment/service-identity --timeout=300s

"${ROOT_DIR}/scripts/smoke-test.sh"
