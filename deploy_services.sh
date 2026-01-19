#!/bin/bash
set -e

# Ensure we are in the directory containing this script (repo root)
cd "$(dirname "$0")" || exit

echo "--> Fetching Server IP..."
# Try to get IP, refreshing if needed
if ! terraform output public_ipv4 >/dev/null 2>&1; then
    echo "--> State might be stale, refreshing..."
    terraform refresh >/dev/null
fi

# Robustly extract IP using Python and JSON output
SERVER_IP=$(terraform output -json | python3 -c "import sys, json; print(json.load(sys.stdin).get('public_ipv4', {}).get('value', ''))" 2>/dev/null)

if [ -z "$SERVER_IP" ]; then
    echo "Error: Could not extract 'public_ipv4' from terraform output."
    echo "Debug: Raw output:"
    terraform output
    exit 1
fi

echo "--> Server IP: $SERVER_IP"

echo "--> Checking SSH Connection..."
if ! ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@"$SERVER_IP" exit 2>/dev/null; then
    echo "--------------------------------------------------------"
    echo "ERROR: SSH connection to root@$SERVER_IP failed."
    echo "--------------------------------------------------------"
    echo "Possible reasons:"
    echo "1. The SSH key used for provisioning is not in your agent."
    echo "   Run: ssh-add <path_to_your_private_key>"
    echo "2. The server is still booting up (wait 30s and try again)."
    echo "3. The wrong SSH key was provided to Terraform."
    echo "--------------------------------------------------------"
    exit 1
fi


echo "--> Checking Tailscale status (remote)..."
# Check if tailscale is up and has a valid login
if ssh -o StrictHostKeyChecking=no root@"$SERVER_IP" "tailscale status" | grep -q "Logged out"; then
    echo "--------------------------------------------------------"
    echo "Tailscale is installed but LOGGED OUT."
    echo "Please run the following command manually in a new terminal:"
    echo ""
    echo "    ssh root@$SERVER_IP contrast"  # Just kidding, 'tailscale up'
    echo "    ssh root@$SERVER_IP tailscale up"
    echo ""
    echo "Follow the link it generates, then re-run this script."
    echo "--------------------------------------------------------"
    exit 1
elif ssh -o StrictHostKeyChecking=no root@"$SERVER_IP" "tailscale status" | grep -q "Tailscale is stopped"; then
     echo "--------------------------------------------------------"
    echo "Tailscale is STOPPED."
    echo "Please run: ssh root@$SERVER_IP tailscale up"
    echo "--------------------------------------------------------"
    exit 1
fi

echo "Tailscale seems operational."

echo "--> Syncing service definitions..."
# Ensure default destination directory exists
ssh root@"$SERVER_IP" "mkdir -p /root/services"
scp -r services/* root@"$SERVER_IP":/root/services/

echo "--> Starting Services..."

# Dynamically find all services in the services directory
SERVICES=$(ssh root@"$SERVER_IP" "ls -d /root/services/*/ | xargs -n 1 basename")

for service in $SERVICES; do
    echo "Starting $service..."
    ssh root@"$SERVER_IP" "cd /root/services/$service && docker compose up -d"
done

echo "========================================================"
echo "Deployment Complete!"
echo "Services should be running."
echo "--------------------------------------------------------"
echo "Services should be running at:"
for service in $SERVICES; do
    case $service in
        "n8n")
            echo "- N8N:           https://n8n.yourdomain.com"
            ;;
        "miniflux")
            echo "- Miniflux:      https://rss.yourdomain.com"
            ;;
        "pihole")
            echo "- Pi-hole:       https://pihole.yourdomain.com"
            ;;
        "actual")
            echo "- Actual:        https://actual.yourdomain.com"
            ;;
        "uptime-kuma")
            echo "- Uptime Kuma:   https://status.yourdomain.com"
            ;;
        "monica")
            echo "- Monica CRM:    https://crm.yourdomain.com"
            ;;
        "mealie")
            echo "- Mealie:        https://recipes.yourdomain.com"
            ;;
        "caddy")
            echo "- Caddy:         Reverse proxy running (manages HTTPS)"
            ;;
        *)
            echo "- $service:      (Check docker-compose.yml for port)"
            ;;
    esac
done
echo "========================================================"
