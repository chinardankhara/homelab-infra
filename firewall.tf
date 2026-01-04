resource "hcloud_firewall" "homelab" {
  name = "${var.instance_name}-firewall"

  # SSH Access
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # HTTP
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # HTTPS
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Tailscale WireGuard
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "41641"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # n8n Web UI
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "5678"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Pi-hole Web UI
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "8080"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Miniflux Web UI
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "8081"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
