#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: ./scripts/set-github-org.sh <github-org>"
  exit 1
fi

ORG="$1"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

find "${ROOT_DIR}" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.md" \) \
  -exec sed -i "s/YOUR_GITHUB_ORG/${ORG}/g" {} \;

echo "Updated placeholders to ${ORG}"
