#!/bin/bash
###
# @Author: huyuhao
# @Date: 2024-05-31 19:46:56
###

set -eux
set -o pipefail

packages=(
    jq
    tar
    vim
    zip
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
    ksc-rootfs-autoresize
)

yum install ${packages[*]} -y

packages_el7=(
  zlib-1.2.7-19.el7_9.x86_64
  libxml2-2.9.1-6.el7.5.x86_64
  libxml2-python-2.9.1-6.el7.5.x86_64
)

yum install ${packages_el7[*]} -y



centos_version=$(grep -o '[0-9\.]*' /etc/centos-release | awk -F \. '{print $1}')
case $centos_version in
"6")
    release_packages=()
    ;;
"7")
    release_packages=(
        bash-completion-extras
    )
    ;;
"8")
    release_packages=(
        cloud-init
    )
    ;;
esac

if [ ${#release_packages[*]} != "0" ]; then
    yum install ${release_packages[*]} -y
fi

case $centos_version in
"6")
    yum update -x centos-release -y --disablerepo=kec,sdn
    ;;
"7") ;;

"8") ;;

esac

reboot
sleep 10

