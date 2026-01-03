resource "hcloud_ssh_key" "homelab" {
  name       = var.ssh_key_name
  public_key = var.ssh_public_key
}

resource "hcloud_server" "homelab" {
  name        = var.instance_name
  server_type = var.instance_type
  location    = var.region
  image       = "ubuntu-24.04"

  ssh_keys = [hcloud_ssh_key.homelab.id]

  firewall_ids = [hcloud_firewall.homelab.id]

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    tailscale_authkey = var.tailscale_authkey
  })

  labels = {
    environment = "homelab"
    managed_by  = "terraform"
  }

  # Optional: Uncomment to attach to private network
  # network {
  #   network_id = hcloud_network.homelab.id
  #   ip         = "10.0.1.2"
  # }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
