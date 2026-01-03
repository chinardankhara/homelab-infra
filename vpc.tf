# Optional: Private network for future expansion
# Uncomment if you want to add private networking between multiple servers

# resource "hcloud_network" "homelab" {
#   name     = "${var.instance_name}-network"
#   ip_range = "10.0.0.0/16"
# }

# resource "hcloud_network_subnet" "homelab" {
#   network_id   = hcloud_network.homelab.id
#   type         = "cloud"
#   network_zone = "us-east"
#   ip_range     = "10.0.1.0/24"
# }
