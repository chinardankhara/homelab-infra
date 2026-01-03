# Quick Deployment Guide

## ✅ Pre-flight Checklist

- [ ] Hetzner Cloud account created
- [ ] API token generated (Project → Security → API Tokens)
- [ ] SSH key pair ready (`~/.ssh/id_ed25519.pub`)
- [ ] Tailscale auth key (optional, from https://login.tailscale.com/admin/settings/keys)

## 🚀 Deployment Steps

### 1. Configure Variables

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Required values:**
```hcl
hcloud_token   = "your-hetzner-api-token-here"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... your-email@example.com"
```

**Optional values:**
```hcl
tailscale_authkey = "tskey-auth-xxxxx"  # Leave empty to configure manually later
ssh_key_name      = "homelab-key"
instance_name     = "homelab-vps"
```

### 2. Preview Changes

```bash
terraform plan
```

**Expected output:**
- `hcloud_ssh_key.homelab` will be created
- `hcloud_firewall.homelab` will be created
- `hcloud_server.homelab` will be created

**Cost:** ~€4.51/month (~$5 USD)

### 3. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

**Deployment time:** ~30-60 seconds for server creation, 2-3 minutes for cloud-init to complete.

### 4. Get Connection Info

```bash
terraform output
```

**Example output:**
```
public_ipv4 = "123.45.67.89"
ssh_command = "ssh root@123.45.67.89"
```

### 5. Connect and Verify

```bash
# SSH to server (wait 2-3 minutes for cloud-init to finish)
ssh root@<public-ipv4>

# Check cloud-init status
cloud-init status

# Verify Docker
docker --version
docker compose version

# Verify Tailscale
tailscale status
```

## 🔧 Post-Deployment Configuration

### If Tailscale Auth Key Was NOT Provided

```bash
ssh root@<public-ipv4>
tailscale up
# Follow the authentication URL
```

### Deploy Your First Service

```bash
# Create a docker-compose.yml
cat > docker-compose.yml <<EOF
version: '3.8'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    restart: unless-stopped
EOF

# Start the service
docker compose up -d

# Verify
curl http://localhost
```

## 🧹 Teardown

```bash
# Destroy all resources
terraform destroy

# Type 'yes' to confirm
```

## 📊 Resource Summary

| Resource | Specification |
|----------|---------------|
| **Provider** | Hetzner Cloud |
| **Region** | Ashburn (ash) |
| **Instance** | CAX11 (ARM64) |
| **vCPU** | 2 cores |
| **RAM** | 4 GB |
| **Storage** | 40 GB SSD |
| **Traffic** | 20 TB/month |
| **Cost** | €4.51/month |

## 🔐 Security Checklist

- [x] Firewall configured (SSH, HTTP, HTTPS, Tailscale only)
- [x] SSH key authentication (no password login)
- [ ] Configure fail2ban (recommended)
- [ ] Set up automatic security updates
- [ ] Configure Tailscale for secure remote access
- [ ] Use Terraform remote backend for state (production)

## 🆘 Troubleshooting

### Can't SSH to server

```bash
# Check if server is running
terraform show | grep status

# Wait for cloud-init
ssh root@<ip> 'tail -f /var/log/cloud-init-output.log'
```

### Docker not installed

```bash
# Check cloud-init status
ssh root@<ip> 'cloud-init status --wait'

# View logs
ssh root@<ip> 'cat /var/log/cloud-init-output.log'
```

### Terraform errors

```bash
# Re-initialize
terraform init -upgrade

# Validate configuration
terraform validate

# Check formatting
terraform fmt -check
```

## 📝 Next Steps

1. **Set up monitoring**: Prometheus, Grafana, or Uptime Kuma
2. **Configure backups**: Hetzner Cloud Backups or custom solution
3. **Deploy applications**: Pi-hole, Home Assistant, etc.
4. **Set up CI/CD**: GitHub Actions for automated deployments
5. **Configure DNS**: Point your domain to the server IP
