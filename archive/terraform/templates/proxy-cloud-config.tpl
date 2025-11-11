#cloud-config
hostname: ${hostname}
fqdn: ${hostname}
timezone: Europe/Moscow

apt:
  sources:
    docker.list:
      source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

package_upgrade: true
packages:
  - qemu-guest-agent
  - net-tools
  - iputils-ping
  - vim
  - apt-transport-https
  - ca-certificates
  - gnupg-agent
  - docker-ce
  - docker-ce-cli
  - containerd.io
  - git

users:
  - default
  - name: ${user}
    groups:
      - sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
password: pass

write_files:
  - path: /etc/sysctl.d/enabled_ipv4_forwarding.conf
    content: |
      net.ipv4.conf.all.forwarding=1
  - content: ${cert_crt}
    encoding: b64
    path: /opt/frp_certs/cert.crt
    permissions: '0644'
  - content: ${cert_key}
    encoding: b64
    path: /opt/frp_certs/cert.key
    permissions: '0644'
  - content: ${ca_crt}
    encoding: b64
    path: /opt/frp_certs/ca.crt
    permissions: '0644'

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent