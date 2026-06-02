#!/usr/bin/env bash
set -euo pipefail

echo "== OS =="
lsb_release -a || true

echo
echo "== Memory =="
free -h

echo
echo "== Disk =="
df -h /

echo
echo "== Docker =="
docker --version
docker compose version

echo
echo "== Running containers =="
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"

echo
echo "== Important ports =="
ss -tulpn | grep -E ':80|:443|:3000|:5432|:6379' || true

echo
echo "== Nginx sites =="
ls -la /etc/nginx/sites-enabled || true

