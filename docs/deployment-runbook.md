# Chatwoot Docker Deployment Runbook

Replace:

- `<VPS_IP>` with the VPS IP
- `<CHATWOOT_DOMAIN>` with the Chatwoot subdomain
- `<ADMIN_EMAIL>` with the first admin email

Run one command at a time.

## 1. SSH

```bash
ssh root@<VPS_IP>
```

## 2. Inspect Server

```bash
lsb_release -a
```

```bash
free -h
```

```bash
df -h
```

## 3. Inspect Existing Services

```bash
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"
```

```bash
ss -tulpn | grep -E ':80|:443|:3000|:5432|:6379'
```

```bash
ls -la /etc/nginx/sites-enabled
```

Do not continue until you understand what already uses Nginx and Docker.

## 4. Create App Directory

```bash
mkdir -p /opt/chatwoot
```

```bash
cd /opt/chatwoot
```

## 5. Download Official Chatwoot Files

```bash
wget -O .env https://raw.githubusercontent.com/chatwoot/chatwoot/develop/.env.example
```

```bash
wget -O docker-compose.yaml https://raw.githubusercontent.com/chatwoot/chatwoot/develop/docker-compose.production.yaml
```

## 6. Configure Secrets

```bash
cp .env .env.bak
```

```bash
SECRET_KEY_BASE=$(openssl rand -hex 64)
```

```bash
REDIS_PASSWORD=$(openssl rand -hex 32)
```

```bash
POSTGRES_PASSWORD=$(openssl rand -hex 32)
```

```bash
sed -i "s|^SECRET_KEY_BASE=.*|SECRET_KEY_BASE=$SECRET_KEY_BASE|" .env
```

```bash
sed -i "s|^FRONTEND_URL=.*|FRONTEND_URL=https://<CHATWOOT_DOMAIN>|" .env
```

```bash
sed -i "s|^RAILS_ENV=.*|RAILS_ENV=production|" .env
```

```bash
sed -i "s|^ENABLE_ACCOUNT_SIGNUP=.*|ENABLE_ACCOUNT_SIGNUP=true|" .env
```

```bash
sed -i "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=$REDIS_PASSWORD|" .env
```

```bash
sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$POSTGRES_PASSWORD|" .env
```

```bash
sed -i "s|POSTGRES_PASSWORD=|POSTGRES_PASSWORD=$POSTGRES_PASSWORD|" docker-compose.yaml
```

## 7. Prepare Database

```bash
docker compose run --rm rails bundle exec rails db:chatwoot_prepare
```

If the first run creates the database but shows a missing database warning, start services and run it again.

## 8. Start Chatwoot

```bash
docker compose up -d
```

```bash
docker compose ps
```

```bash
curl -I http://127.0.0.1:3000
```

Expected: `302 Found` to `/installation/onboarding`.

## 9. Add Nginx Site

```bash
nano /etc/nginx/sites-available/<CHATWOOT_DOMAIN>
```

Paste `nginx/chatwoot.conf.template` and replace `<CHATWOOT_DOMAIN>`.

```bash
ln -s /etc/nginx/sites-available/<CHATWOOT_DOMAIN> /etc/nginx/sites-enabled/<CHATWOOT_DOMAIN>
```

```bash
nginx -t
```

```bash
systemctl reload nginx
```

```bash
curl -I http://<CHATWOOT_DOMAIN>
```

## 10. Install SSL

```bash
certbot --nginx -d <CHATWOOT_DOMAIN>
```

```bash
curl -I https://<CHATWOOT_DOMAIN>
```

Expected: `302 Found` to `/installation/onboarding`.

## 11. First Admin Account

Ask the client to open:

```text
https://<CHATWOOT_DOMAIN>
```

The client should create the first admin account.

## 12. Disable Public Signup

After the first admin account is created:

```bash
cd /opt/chatwoot
```

```bash
sed -i "s|^ENABLE_ACCOUNT_SIGNUP=.*|ENABLE_ACCOUNT_SIGNUP=false|" .env
```

```bash
docker compose restart rails sidekiq
```

## 13. SMTP Later

Add these to `/opt/chatwoot/.env` when available:

```bash
MAILER_SENDER_EMAIL=Your Brand <no-reply@example.com>
SMTP_ADDRESS=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=username
SMTP_PASSWORD=password
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

Then restart:

```bash
docker compose restart rails sidekiq
```

