#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OWNER="${GHCR_OWNER:-your-org}"
REPO="${GHCR_REPO:-developer-portal}"
TAG="${IMAGE_TAG:-latest}"

eval "$(minikube -p minikube docker-env)"

docker build -f "${ROOT_DIR}/docker/backstage-backend.Dockerfile" -t "ghcr.io/${OWNER}/${REPO}/backstage-backend:${TAG}" "${ROOT_DIR}"
docker build -f "${ROOT_DIR}/docker/backstage-frontend.Dockerfile" -t "ghcr.io/${OWNER}/${REPO}/backstage-frontend:${TAG}" "${ROOT_DIR}"
docker build -f "${ROOT_DIR}/services/service-catalog/Dockerfile" -t "ghcr.io/${OWNER}/${REPO}/service-catalog:${TAG}" "${ROOT_DIR}/services/service-catalog"
docker build -f "${ROOT_DIR}/services/service-identity/Dockerfile" -t "ghcr.io/${OWNER}/${REPO}/service-identity:${TAG}" "${ROOT_DIR}/services/service-identity"

echo "Local images built in Minikube cache with tag ${TAG}"
