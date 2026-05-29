#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DASHBOARD_FILE="${ROOT_DIR}/monitoring/grafana/dashboards/developer-portal-overview.json"

if ! kubectl -n monitoring get svc kube-prom-stack-grafana >/dev/null 2>&1; then
  echo "Grafana service not found, skip dashboard import."
  exit 0
fi

GRAFANA_USER="$(kubectl -n monitoring get secret kube-prom-stack-grafana -o jsonpath='{.data.admin-user}' | base64 --decode)"
GRAFANA_PASSWORD="$(kubectl -n monitoring get secret kube-prom-stack-grafana -o jsonpath='{.data.admin-password}' | base64 --decode)"

kubectl -n monitoring port-forward svc/kube-prom-stack-grafana 3000:80 >/tmp/grafana-port-forward.log 2>&1 &
PF_PID=$!
trap 'kill ${PF_PID} >/dev/null 2>&1 || true' EXIT
sleep 5

PAYLOAD="$(jq -n --argjson dashboard "$(cat "${DASHBOARD_FILE}")" '{dashboard: $dashboard, folderId: 0, overwrite: true}')"

curl -sS -u "${GRAFANA_USER}:${GRAFANA_PASSWORD}" \
  -H "Content-Type: application/json" \
  -X POST \
  -d "${PAYLOAD}" \
  http://127.0.0.1:3000/api/dashboards/db >/dev/null

echo "Grafana dashboard imported."
