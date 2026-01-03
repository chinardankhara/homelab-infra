variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key content for server access"
  type        = string
}

variable "ssh_key_name" {
  description = "Name for the SSH key resource in Hetzner Cloud"
  type        = string
  default     = "homelab-key"
}

variable "region" {
  description = "Hetzner Cloud region/location"
  type        = string
  default     = "ash"
}

variable "instance_type" {
  description = "Hetzner Cloud server type"
  type        = string
  default     = "cpx21"
}

variable "instance_name" {
  description = "Name for the server instance"
  type        = string
  default     = "homelab-vps"
}

variable "tailscale_authkey" {
  description = "Tailscale authentication key (optional, can be empty)"
  type        = string
  sensitive   = true
  default     = ""
}
