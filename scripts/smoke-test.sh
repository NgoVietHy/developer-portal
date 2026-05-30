#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="developer-portal"

kubectl -n "${NAMESPACE}" get pods

kubectl -n "${NAMESPACE}" run curl-smoke --image=curlimages/curl:8.8.0 --restart=Never --rm --attach --command -- \
  sh -c "curl -fsS http://service-catalog:8081/health && curl -fsS http://service-identity:8082/health >/dev/null"

echo "Smoke tests passed."
