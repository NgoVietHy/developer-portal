#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

ZIP_PATH="${1:-/root/developer-portal-upload.zip}"
DEPLOY_DIR="${2:-/opt/developer-portal}"

if [[ ! -f "${ZIP_PATH}" ]]; then
  echo "ZIP file not found: ${ZIP_PATH}"
  exit 1
fi

apt-get update >/dev/null
apt-get install -y unzip >/dev/null

mkdir -p "${DEPLOY_DIR}"
find "${DEPLOY_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
unzip -oq "${ZIP_PATH}" -d "${DEPLOY_DIR}"

cd "${DEPLOY_DIR}"
chmod +x scripts/*.sh

./scripts/ubuntu-setup.sh
systemctl enable --now docker
./scripts/bootstrap-minikube.sh
./scripts/smoke-test.sh

echo "VPS deployment completed from ZIP."
