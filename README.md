# 🏠 Homelab Infrastructure

A complete self-hosted stack on Hetzner Cloud with automatic HTTPS. **~€7.50/month**.

## What You Get

| Service | Purpose | URL |
|---------|---------|-----|
| **Actual Budget** | Privacy-focused budgeting | `actual.yourdomain.com` |
| **n8n** | Workflow automation | `n8n.yourdomain.com` |
| **Miniflux** | Minimalist RSS reader | `rss.yourdomain.com` |
| **Pi-hole** | Network-wide ad blocking | `pihole.yourdomain.com` |
| **Uptime Kuma** | Uptime monitoring | `status.yourdomain.com` |
| **Monica** | Personal CRM | `crm.yourdomain.com` |
| **Mealie** | Recipe manager | `recipes.yourdomain.com` |

All services run behind **Caddy** with automatic HTTPS certificates.

---

## Quick Start (< 5 minutes)

### Prerequisites
- [Terraform](https://terraform.io) installed
- [Hetzner Cloud](https://hetzner.cloud) account + API token
- Domain with DNS access
- SSH key pair (`ssh-keygen -t ed25519`)

### 1. Clone & Setup

```bash
git clone https://github.com/YOUR_USERNAME/homelab-infra.git
cd homelab-infra

# Create your config files
cp terraform.tfvars.example terraform.tfvars
cp .env.example .env
```

### 2. Configure Terraform

Edit `terraform.tfvars`:
```hcl
hcloud_token   = "your-hetzner-api-token"
ssh_public_key = "ssh-ed25519 AAAA... you@email.com"
ssh_key_name   = "homelab-key"
```

### 3. Configure Services

**Option A: Quick (use defaults, change passwords later in UI)**
- Just update your domain in the files below

**Option B: Secure (recommended)**
- Generate secrets:
  ```bash
  openssl rand -base64 32  # For Monica APP_KEY
  openssl rand -base64 16  # For passwords
  ```
- Copy and edit service configs:
  ```bash
  mkdir -p local/services/{monica,caddy,mealie,n8n,miniflux}
  cp services/monica/docker-compose.yml local/services/monica/
  cp services/caddy/Caddyfile local/services/caddy/
  # ... edit with your domain and secrets
  ```

### 4. Update Domain

Replace `yourdomain.com` with your domain:
```bash
# In services/caddy/Caddyfile (or local/services/caddy/Caddyfile)
# In services/monica/docker-compose.yml
# In services/mealie/docker-compose.yml  
# In deploy_services.sh
```

Or use sed:
```bash
find services -type f \( -name "*.yml" -o -name "Caddyfile" \) \
  -exec sed -i '' 's/yourdomain\.com/YOUR_DOMAIN/g' {} \;
sed -i '' 's/yourdomain\.com/YOUR_DOMAIN/g' deploy_services.sh
```

### 5. Deploy Infrastructure

```bash
terraform init
terraform apply
# Note the IP address from output
```

### 6. Add DNS Records

Create A records pointing to your server IP:

| Host | Value |
|------|-------|
| `actual` | `SERVER_IP` |
| `n8n` | `SERVER_IP` |
| `rss` | `SERVER_IP` |
| `pihole` | `SERVER_IP` |
| `status` | `SERVER_IP` |
| `crm` | `SERVER_IP` |
| `recipes` | `SERVER_IP` |

### 7. Deploy Services

```bash
ssh-add ~/.ssh/your_private_key
./deploy_services.sh
```

Done! Wait a few minutes for DNS propagation and HTTPS certificates.

---

## Project Structure

```
homelab-infra/
├── services/           # Service definitions (templates)
│   ├── actual/
│   ├── caddy/          # Reverse proxy config
│   ├── mealie/
│   ├── miniflux/
│   ├── monica/
│   ├── n8n/
│   ├── pihole/
│   └── uptime-kuma/
├── local/              # Your overrides (gitignored)
│   └── services/       # Put your real configs here
├── compute.tf          # Server definition
├── firewall.tf         # Firewall rules
├── cloud-init.yaml     # Server bootstrap (Docker, Tailscale)
├── deploy_services.sh  # Deployment script
└── terraform.tfvars.example
```

---

## How Local Overrides Work

The `services/` folder contains templates with placeholder values.

Your real configs go in `local/services/` which is gitignored.

**Deploy script behavior:**
1. Syncs `services/*` to server (templates)
2. Overlays `local/services/*` on top (your real configs)

This lets you share the repo without exposing secrets.

---

## Adding Services

1. Create `services/yourservice/docker-compose.yml`
2. Add entry to `services/caddy/Caddyfile`
3. Add DNS record
4. Run `./deploy_services.sh`

---

## Security Notes

- Change all `CHANGE_ME` passwords before deploying
- Pi-hole generates a random password on first run (check logs)
- All traffic is HTTPS via Caddy
- Consider using Tailscale for private access

---

## Costs

| Item | Cost |
|------|------|
| Hetzner CPX21 (3 vCPU, 4GB RAM) | ~€7.50/month |
| Domain | ~$10-15/year |

---

## License

MIT

---

## 🔐 A Note for the Curious

If you're spelunking through git history hoping to find any secrets, don't bother. 
All credentials have been rotated. You're welcome to waste your time though.

