#!/bin/bash
###
 # @Author: xuanyu
 # @Date: 2021-10-05 13:56:51
###

set -eux
set -o pipefail

PKGS=(
    "ipmitool"
    "genisoimage"
    "curl"
    "dmidecode"
    "lshw"
    "qemu-kvm-core"
    "qemu-img"
    "gcc"
    "parted"
    "hdparm"
    "util-linux"
    "gdisk"
    "kmod"
    "psmisc"
    "dosfstools"
    "efibootmgr"
    "efivar"
    "bash-completion"
    "http://luna.galaxy.ksyun.com/galaxy/thridpart/storcli-1.21.06-1.noarch.rpm"
)

yum install ${PKGS[@]} -y

cat << EOF > /tmp/disk-image-installer.service
[Unit]
Description=Disk-image-installer
After=network-online.target

[Service]
ExecStartPre=test -e /dev/disk/by-label/penglai
ExecStart=/init.sh
Type=oneshot

[Install]
WantedBy=multi-user.target

EOF

cat << EOF > /tmp/init.sh
#!/bin/bash

set -eu
set -o pipefail

export LC_ALL=C.UTF-8

if ! mountpoint -q /mnt
then
    mount /dev/disk/by-label/penglai /mnt
fi
/mnt/init.sh
EOF

install -D -g root -o root -m 0644 /tmp/disk-image-installer.service /usr/lib/systemd/system/disk-image-installer.service
install -D -g root -o root -m 0755 /tmp/init.sh /init.sh
rm -f /tmp/disk-image-installer.service /tmp/init.sh
systemctl daemon-reload
systemctl enabled disk-image-installer.service