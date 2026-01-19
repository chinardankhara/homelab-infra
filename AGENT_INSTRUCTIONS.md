# Agent Instructions: Homelab Infrastructure

You are helping a user deploy a self-hosted homelab on Hetzner Cloud.

## Overview

This repository provisions a VPS with Docker and deploys these services:
- Actual Budget, n8n, Miniflux, Pi-hole, Uptime Kuma, Monica CRM, Mealie
- All behind Caddy reverse proxy with automatic HTTPS

## Prerequisites to Verify

Before proceeding, confirm the user has:
1. Terraform installed (`terraform --version`)
2. Hetzner Cloud account with API token
3. A domain they control
4. SSH key pair (or generate with `ssh-keygen -t ed25519 -f ~/.ssh/homelab_key`)

## Deployment Steps

### Step 1: Create Configuration Files

```bash
cp terraform.tfvars.example terraform.tfvars
cp .env.example .env
```

### Step 2: Configure terraform.tfvars

User must provide:
- `hcloud_token`: Hetzner API token (from Hetzner Console → Security → API Tokens)
- `ssh_public_key`: Contents of their public key file (e.g., `~/.ssh/id_ed25519.pub`)
- `ssh_key_name`: Any name for the key

### Step 3: Generate Secrets

Run these to generate secure values:
```bash
# Monica APP_KEY
echo "MONICA_APP_KEY=base64:$(openssl rand -base64 32)"

# Database passwords
echo "MONICA_DB_PASSWORD=$(openssl rand -base64 16)"
echo "MINIFLUX_DB_PASSWORD=$(openssl rand -base64 16)"
echo "N8N_PASSWORD=$(openssl rand -base64 16)"
```

### Step 4: Create Local Override Files

Create `local/services/` with the user's real configs:

```bash
mkdir -p local/services/{caddy,monica,mealie,n8n,miniflux}
```

For each service, copy from `services/` and replace:
- `yourdomain.com` → user's actual domain
- `CHANGE_ME*` → generated secrets

**Critical files to customize:**
- `local/services/caddy/Caddyfile` - Replace all `yourdomain.com`
- `local/services/monica/docker-compose.yml` - Replace APP_KEY and passwords
- `local/services/mealie/docker-compose.yml` - Replace BASE_URL domain
- `local/services/n8n/docker-compose.yml` - Replace password
- `local/services/miniflux/docker-compose.yml` - Replace passwords

### Step 5: Deploy Infrastructure

```bash
terraform init
terraform apply
```

Capture the output IP address for DNS configuration.

### Step 6: Configure DNS

User must add A records in their DNS provider:

| Subdomain | Record Type | Value |
|-----------|-------------|-------|
| actual | A | SERVER_IP |
| n8n | A | SERVER_IP |
| rss | A | SERVER_IP |
| pihole | A | SERVER_IP |
| status | A | SERVER_IP |
| crm | A | SERVER_IP |
| recipes | A | SERVER_IP |

### Step 7: Deploy Services

```bash
ssh-add ~/.ssh/homelab_key  # or their key path
./deploy_services.sh
```

## File Structure Reference

```
services/           → Templates (committed, has CHANGE_ME placeholders)
local/services/     → User's real configs (gitignored, has actual secrets)
terraform.tfvars    → User's Hetzner credentials (gitignored)
.env                → User's env vars (gitignored)
```

## Common Issues

### SSH Connection Failed
- Run `ssh-add /path/to/private/key`
- Wait 30s if server just booted

### Service Not Accessible
- Check DNS propagation: `dig subdomain.domain.com`
- Check Caddy logs: `ssh root@IP "docker logs caddy"`
- Verify firewall allows ports 80, 443

### HTTPS Certificate Issues
- Caddy auto-provisions certs; wait a few minutes
- Ensure DNS is pointing to correct IP

## Adding a New Service

1. Create `services/newservice/docker-compose.yml`
2. Add reverse proxy entry to `services/caddy/Caddyfile`:
   ```
   newservice.yourdomain.com {
       reverse_proxy host.docker.internal:PORT
   }
   ```
3. Update `deploy_services.sh` case statement for URL output
4. Add DNS record
5. Run `./deploy_services.sh`

## Important Reminders

- Never commit `terraform.tfvars`, `.env`, or `local/` folder
- All passwords should be unique and randomly generated
- The `local/services/` folder overlays `services/` during deployment
