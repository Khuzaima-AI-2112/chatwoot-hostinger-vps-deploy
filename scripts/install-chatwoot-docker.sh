#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-}"

if [[ -z "$DOMAIN" ]]; then
  echo "Usage: ./scripts/install-chatwoot-docker.sh <chatwoot-domain>"
  exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

mkdir -p /opt/chatwoot
cd /opt/chatwoot

if [[ ! -f .env ]]; then
  wget -O .env https://raw.githubusercontent.com/chatwoot/chatwoot/develop/.env.example
fi

if [[ ! -f docker-compose.yaml ]]; then
  wget -O docker-compose.yaml https://raw.githubusercontent.com/chatwoot/chatwoot/develop/docker-compose.production.yaml
fi

cp .env ".env.bak.$(date +%Y%m%d%H%M%S)"

SECRET_KEY_BASE="$(openssl rand -hex 64)"
REDIS_PASSWORD="$(openssl rand -hex 32)"
POSTGRES_PASSWORD="$(openssl rand -hex 32)"

sed -i "s|^SECRET_KEY_BASE=.*|SECRET_KEY_BASE=$SECRET_KEY_BASE|" .env
sed -i "s|^FRONTEND_URL=.*|FRONTEND_URL=https://$DOMAIN|" .env
sed -i "s|^RAILS_ENV=.*|RAILS_ENV=production|" .env
sed -i "s|^ENABLE_ACCOUNT_SIGNUP=.*|ENABLE_ACCOUNT_SIGNUP=true|" .env
sed -i "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=$REDIS_PASSWORD|" .env
sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$POSTGRES_PASSWORD|" .env
sed -i "s|POSTGRES_PASSWORD=|POSTGRES_PASSWORD=$POSTGRES_PASSWORD|" docker-compose.yaml

docker compose run --rm rails bundle exec rails db:chatwoot_prepare || true
docker compose up -d
docker compose run --rm rails bundle exec rails db:chatwoot_prepare

cat > "/etc/nginx/sites-available/$DOMAIN" <<NGINX
server {
    listen 80;
    server_name $DOMAIN;

    client_max_body_size 50M;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Ssl on;

        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_read_timeout 3600;
        proxy_send_timeout 3600;
    }
}
NGINX

ln -sfn "/etc/nginx/sites-available/$DOMAIN" "/etc/nginx/sites-enabled/$DOMAIN"
nginx -t
systemctl reload nginx

certbot --nginx -d "$DOMAIN"

echo "Chatwoot is ready: https://$DOMAIN"
echo "Create the first admin account, then run scripts/disable-signup.sh."

