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
        jq
        tar
        vim
        zip
        zlib
        wget
        tree
        unzip
        lldpd
        lrzsz
        parted
        tcpdump
        ethtool
        pciutils
        nvme-cli
        ipmitool
        rng-tools
        dmidecode
        traceroute
        util-linux-ng
        smartmontools
        bash-completion
        lldp
        cloud-init
        genisoimage
        qemu-img
        gcc
    )
    yum install ${packages[*]} -y
}

function docker() {
    yum remove docker docker-common docker-selinux docker-engine -y
    yum install -y yum-utils device-mapper-persistent-data lvm2 docker-ce rsync lldp
    systemctl enable docker.service
    mkdir -p /etc/docker/
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
    cat > /node-init.sh << EOF
#!/bin/bash
set -eux
set -o pipefail

export LC_ALL=C.UTF-8

DATA_PATH=/data/packages

if [[ ! -d "\$DATA_PATH" ]]
then
    mkdir -p "\$DATA_PATH"
fi

if ! mountpoint -q "\$DATA_PATH"
then
    mount /dev/disk/by-label/penglai "\$DATA_PATH"
fi
bash "\$DATA_PATH"/houyi/packages/youchao-bootstrap/node-init.sh
EOF
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
function e2fsprogs() {
	cd /root/
	tar zxf e2fsprogs-1.43.1.tar.gz
	cd e2fsprogs-1.43.1
	./configure
	make && make install
}

function main() {
    packages
    docker
    node-init
    ipmi_modules
    e2fsprogs
}


main
