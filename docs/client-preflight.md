# Client Preflight Questions

Ask these before touching the VPS.

## 1. VPS Confirmation

Question:

```text
Can you confirm the exact VPS IP where Chatwoot should be installed, and whether the VPS is empty or already hosts apps, websites, databases, or email services?
```

Recommended approval:

```text
Yes, install Chatwoot on VPS <VPS_IP>. The VPS may be modified for Chatwoot. Existing apps must not be broken.
```

## 2. Domain Confirmation

Question:

```text
Can you confirm the final Chatwoot URL and DNS A record?
```

Recommended approval:

```text
Use https://<CHATWOOT_DOMAIN>. The DNS A record points to <VPS_IP> and is DNS-only, not proxied.
```

## 3. OS Confirmation

Question:

```text
Which Ubuntu version is installed?
```

Recommended:

```text
Ubuntu 22.04 LTS or Ubuntu 24.04 LTS.
```

## 4. Shared VPS Approval

Question:

```text
Do you approve installing Chatwoot with Docker Compose and adding a dedicated Nginx reverse proxy for <CHATWOOT_DOMAIN>?
```

Recommended approval:

```text
Yes. You may install and configure Chatwoot, PostgreSQL, Redis, Nginx site config, SSL, firewall rules, and required packages, while preserving existing services.
```

## 5. Admin Account

Question:

```text
Who should create the first Chatwoot admin account?
```

Recommended:

```text
The client should create the first admin account. After that, public signup should be disabled.
```

## 6. SMTP

Question:

```text
Do you have SMTP credentials for invitation and password reset emails?
```

Recommended:

```text
SMTP can be configured later, but invites and password resets will not work until SMTP is added.
```

