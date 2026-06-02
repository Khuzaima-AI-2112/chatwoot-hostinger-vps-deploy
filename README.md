# Chatwoot Hostinger VPS Deployment Kit

Reusable deployment kit for installing Chatwoot open-source/self-hosted on a Hostinger VPS without breaking existing apps such as Odoo or Dolibarr.

This approach runs Chatwoot with Docker Compose on `127.0.0.1:3000`, then exposes it through an existing host Nginx using a dedicated subdomain.

## What This Installs

- Chatwoot Docker containers
- PostgreSQL container for Chatwoot
- Redis container for Chatwoot
- Nginx reverse proxy site for the Chatwoot subdomain
- Let's Encrypt SSL via Certbot

## What This Does Not Include

- VPS passwords
- SSH keys
- SMTP credentials
- Client-specific generated secrets
- Existing client Nginx configs

## Recommended VPS

- Ubuntu 22.04 LTS or 24.04 LTS
- 4 GB RAM minimum, 8 GB recommended
- 40 GB disk minimum
- Ports `80` and `443` available through host Nginx
- Docker and Docker Compose installed

## Fast Path

Use the runbook:

```bash
docs/deployment-runbook.md
```

For a new client, first complete:

```bash
docs/client-preflight.md
```

## Important Safety Rule

Do not run a blind Chatwoot Linux VM installer on a VPS that already hosts apps. Inspect existing Docker containers and Nginx sites first.

