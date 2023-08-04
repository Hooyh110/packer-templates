#!/bin/bash
###
# @Author: xuanyu
# @Date: 2022-02-17 15:10:28
###

set -eux
set -o pipefail

function packages() {
    packages=(
        rsync
    )
    yum install ${packages[*]} -y
}

function docker() {
    yum remove docker docker-common docker-selinux docker-engine -y
    yum install -y yum-utils device-mapper-persistent-data lvm2 docker-ce
    systemctl enable docker.service
    mkdir /etc/docker/
    cat <<EOF >/etc/docker/daemon.json
{
  "insecure-registries": ["127.0.0.1"],
  "storage-driver": "vfs",
  "graph":"/var/docker/lib",
  "bip": "192.168.0.1/24"
}
EOF
}

function node-init() {
    chmod 755 /node-init.sh
    cat >/usr/lib/systemd/system/node-init.service <<EOF
[Unit]
Description=Initialize the first node for the first time
After=network-online.target
[Service]
ExecStartPre=/usr/bin/test -e /dev/disk/by-label/penglai
ExecStart=/node-init.sh
Type=oneshot
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable node-init
}

function ipmi_modules() {
    echo "ipmi_devintf" >> /etc/modules-load.d/ipmi_modules.conf
    echo "ipmi_si" >> /etc/modules-load.d/ipmi_modules.conf
}

function main() {
    packages
    docker
    node-init
    ipmi_modules
}


main