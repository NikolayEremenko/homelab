
variable "proxmox_endpoint" {
  description = "Cluster endpoint"
  type        = string
  default     = "https://pve-homelab:8006/"
}

variable "proxmox_ssh_username" {
  description = "SSH username"
  type        = string
}

variable "proxmox_api_token" {
  description = "Api token"
  type        = string
  sensitive   = true
}

variable "proxmox_pve_node_name" {
  description = "Cluster name"
  type        = string
  default     = "pve"
}

variable "k3s_cluster_token" {
  description = "Env for k3s cluster toke"
  type        = string
  sensitive   = true
}

variable "nodes" {
  description = "Nodes configurate"
  type = map(object({
    role         = string
    cpu          = number
    memory       = number
    disk         = number
    ipv4_address = string
  }))

  default = {
    "server"  = { role = "master", cpu = 2, memory = 4096, disk = 30, ipv4_address = "192.168.1.100/24" }
    "worker1" = { role = "worker", cpu = 4, memory = 8096, disk = 30, ipv4_address = "192.168.1.101/24" }
    "proxy"   = { role = "proxy", cpu = 1, memory = 2048, disk = 5, ipv4_address = "192.168.1.103/24" }
  }
}