#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-}"

if [[ -z "$DOMAIN" ]]; then
  echo "Usage: ./scripts/healthcheck.sh <chatwoot-domain>"
  exit 1
fi

cd /opt/chatwoot
docker compose ps
curl -I "http://127.0.0.1:3000"
curl -I "https://${DOMAIN}"

