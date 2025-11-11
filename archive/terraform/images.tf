resource "proxmox_virtual_environment_download_file" "ubuntu_24" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_pve_node_name
  url          = "https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img"
}