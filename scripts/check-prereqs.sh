#!/usr/bin/env bash
set -euo pipefail

required_tools=(docker kubectl minikube helm node npm trivy)
missing=0

for tool in "${required_tools[@]}"; do
  if command -v "${tool}" >/dev/null 2>&1; then
    echo "[OK] ${tool}: $(command -v "${tool}")"
  else
    echo "[MISSING] ${tool}"
    missing=1
  fi
done

if [[ "${missing}" -eq 1 ]]; then
  exit 1
fi
