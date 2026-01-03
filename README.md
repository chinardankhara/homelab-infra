# Virtual Homelab Infrastructure

Terraform configuration for provisioning a Virtual Homelab VPS on Hetzner Cloud.

## 📋 Overview

- **Provider**: Hetzner Cloud
- **Region**: Ashburn (ash)
- **Instance**: CAX11 (ARM64, 2 vCPU, 4GB RAM)
- **OS**: Ubuntu 24.04 LTS
- **Pre-installed**: Docker, Docker Compose v2, Tailscale

## 🚀 Quick Start

### Prerequisites

1. **Hetzner Cloud Account**: [Sign up here](https://www.hetzner.com/cloud)
2. **API Token**: Generate from Hetzner Cloud Console → Security → API Tokens
3. **SSH Key**: Generate if needed: `ssh-keygen -t ed25519 -C "your-email@example.com"`
4. **Tailscale Account** (optional): [Get auth key](https://login.tailscale.com/admin/settings/keys)

### Installation

```bash
# 1. Clone this repository
git clone <your-repo-url>
cd homelab-infra

# 2. Install Terraform (if not already installed)
# macOS:
brew install terraform

# Linux:
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# 3. Create your variables file
cp terraform.tfvars.example terraform.tfvars

# 4. Edit terraform.tfvars with your values
nano terraform.tfvars
```

### Configuration

Edit `terraform.tfvars`:

```hcl
hcloud_token      = "your-hetzner-api-token"
ssh_public_key    = "ssh-ed25519 AAAAC3... your-email@example.com"
tailscale_authkey = "tskey-auth-xxxxx"  # Optional
```

### Deployment

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply configuration
terraform apply

# View outputs
terraform output
```

## 📦 What Gets Provisioned

| Resource | Description |
|----------|-------------|
| `hcloud_ssh_key` | SSH key for server access |
| `hcloud_firewall` | Firewall rules (SSH, HTTP, HTTPS, Tailscale) |
| `hcloud_server` | CAX11 ARM server in Ashburn |

### Firewall Rules

| Port | Protocol | Purpose |
|------|----------|---------|
| 22 | TCP | SSH |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |
| 41641 | UDP | Tailscale WireGuard |

## 🔧 Post-Deployment

### Connect to Server

```bash
# SSH (output from terraform)
ssh root@<public-ipv4>

# Verify Docker
docker --version
docker compose version

# Verify Tailscale
tailscale status
tailscale ip
```

### Manual Tailscale Setup (if authkey not provided)

```bash
ssh root@<public-ipv4>
tailscale up
# Follow the URL to authenticate
```

## 🗂️ File Structure

```
homelab-infra/
├── provider.tf              # Hetzner Cloud provider config
├── variables.tf             # Input variable definitions
├── terraform.tfvars.example # Template for secrets
├── vpc.tf                   # Private network (optional)
├── firewall.tf              # Security rules
├── compute.tf               # Server instance
├── outputs.tf               # Output values
├── cloud-init.yaml          # Provisioning script
├── .gitignore               # Git exclusions
└── README.md                # This file
```

## 🔐 Security Notes

- **Never commit** `terraform.tfvars` (contains secrets)
- **State files** contain sensitive data - consider [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/configuration)
- **SSH keys**: Only public keys are in Terraform; keep private keys secure
- **API tokens**: Rotate regularly, use read-only tokens where possible
- **Tailscale**: Use ephemeral keys for better security

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy

# Remove Terraform state (optional, be careful!)
rm -rf .terraform terraform.tfstate*
```

## 📚 Additional Resources

- [Hetzner Cloud Docs](https://docs.hetzner.com/cloud/)
- [Terraform Hetzner Provider](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Tailscale Docs](https://tailscale.com/kb/)

## 💰 Cost Estimate

- **CAX11 (ARM)**: ~€4.51/month (~$5/month)
- **Traffic**: 20TB included
- **Backups**: Optional, +20% of server cost

## 🛠️ Troubleshooting

### Server not accessible after apply

```bash
# Check server status
terraform show | grep status

# Wait 2-3 minutes for cloud-init to complete
ssh root@<ip> 'tail -f /var/log/cloud-init-output.log'
```

### Docker not installed

```bash
# Cloud-init may still be running
ssh root@<ip> 'cloud-init status'

# Check logs
ssh root@<ip> 'journalctl -u cloud-init -f'
```

### Tailscale not connected

```bash
ssh root@<ip>
tailscale up --authkey=<your-key>
```

## 📝 License

MIT
