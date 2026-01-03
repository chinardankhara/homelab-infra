output "server_id" {
  description = "Hetzner Cloud server ID"
  value       = hcloud_server.homelab.id
}

output "server_name" {
  description = "Server hostname"
  value       = hcloud_server.homelab.name
}

output "public_ipv4" {
  description = "Public IPv4 address"
  value       = hcloud_server.homelab.ipv4_address
}

output "public_ipv6" {
  description = "Public IPv6 address"
  value       = hcloud_server.homelab.ipv6_address
}

output "ssh_command" {
  description = "SSH connection command"
  value       = "ssh root@${hcloud_server.homelab.ipv4_address}"
}

output "server_status" {
  description = "Server status"
  value       = hcloud_server.homelab.status
}

output "tailscale_note" {
  description = "Note about Tailscale IP"
  value       = "Tailscale IP available after provisioning. SSH to server and run: tailscale ip"
}
