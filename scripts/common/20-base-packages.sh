#!/bin/bash

set -eux
set -o pipefail

packages=(
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
    lldpd
    elfutils-libelf
    elfutils-libelf-devel
)

yum install ${packages[*]} -y --skip-broken

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
