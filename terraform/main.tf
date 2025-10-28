data "local_file" "ssh_public_key" {
  filename = "../keys/nere@k3s.pub"
}

data "local_file" "ca_crt" {
  filename = "../frp/certs/ca.crt"
}

data "local_file" "cert_crt" {
  filename = "../frp/certs/cert.crt"
}

data "local_file" "cert_key" {
  filename = "../frp/certs/cert.key"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each     = var.nodes
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_pve_node_name

  source_raw {
    data = templatefile("${path.module}/templates/${each.value.role}-cloud-config.tpl", {
      hostname           = each.key
      ssh_key            = trimspace(data.local_file.ssh_public_key.content)
      user               = "nere"
      k3s_cluster_token  = var.k3s_cluster_token
      k3s_server_address = trim(var.nodes["server"].ipv4_address, "/24")
      ca_crt             = base64encode(data.local_file.ca_crt.content)
      cert_crt           = base64encode(data.local_file.cert_crt.content)
      cert_key           = base64encode(data.local_file.cert_key.content)
    })
    file_name = "${each.key}-cloud-config.yml"
  }
}

resource "proxmox_virtual_environment_vm" "k3s-node" {
  for_each    = var.nodes
  name        = each.key
  node_name   = var.proxmox_pve_node_name
  description = "Managed by Terraform"
  tags        = sort(["k3s", "node", "terraform", each.value.role])

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cpu
    numa  = true
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_24.id
    interface    = "scsi0"
    size         = each.value.disk
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id = "local-lvm"

    user_data_file_id = proxmox_virtual_environment_file.cloud_config[each.key].id

    ip_config {
      ipv4 {
        address = each.value.ipv4_address
        gateway = "192.168.1.1"
      }
    }

    user_account {
      username = "nere"
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }
}