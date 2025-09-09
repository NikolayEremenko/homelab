#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.k3s
timezone: Europe/Moscow
package_upgrade: true
packages:
  - qemu-guest-agent
  - net-tools
users:
  - default
  - name: ${user}
    groups:
      - sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent