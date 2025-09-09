
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

variable "nodes" {
  description = "Nodes configurate"
  type = map(object({
    role   = string
    cpu    = number
    memory = number
    disk   = number
  }))
  default = {
    "master01" = { role = "master", cpu = 2, memory = 4096, disk = 30 }
    "worker01" = { role = "worker", cpu = 4, memory = 8096, disk = 30 }
  }
}
