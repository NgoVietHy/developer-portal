#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

PROFILE="${MINIKUBE_PROFILE:-minikube}"
DRIVER="${MINIKUBE_DRIVER:-docker}"

if ! command -v minikube >/dev/null 2>&1; then
  echo "minikube not found. Run setup first."
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found. Run setup first."
  exit 1
fi

if ! command -v socat >/dev/null 2>&1; then
  apt-get update >/dev/null
  apt-get install -y socat >/dev/null
fi

if ! kubectl get nodes --no-headers >/dev/null 2>&1; then
  timeout 900 minikube -p "${PROFILE}" start --driver="${DRIVER}" --force
fi

if docker inspect "${PROFILE}" >/dev/null 2>&1; then
  docker update --restart unless-stopped "${PROFILE}" >/dev/null
fi

cat >/etc/systemd/system/minikube-ingress-forward.service <<EOF
[Unit]
Description=Forward VPS port 80 to Minikube ingress
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Restart=always
RestartSec=5
ExecStart=/bin/bash -lc 'while ! /usr/local/bin/minikube -p ${PROFILE} ip >/dev/null 2>&1; do sleep 2; done; exec /usr/bin/socat TCP-LISTEN:80,reuseaddr,fork TCP:\$(/usr/local/bin/minikube -p ${PROFILE} ip):80'

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now minikube-ingress-forward.service

echo "Systemd services enabled:"
echo "  - minikube-ingress-forward.service"
