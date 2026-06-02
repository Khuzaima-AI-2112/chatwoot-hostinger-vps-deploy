#!/usr/bin/env bash
set -euo pipefail

cd /opt/chatwoot
sed -i "s|^ENABLE_ACCOUNT_SIGNUP=.*|ENABLE_ACCOUNT_SIGNUP=false|" .env
docker compose restart rails sidekiq
docker compose ps

