#!/bin/bash
###
# @Author: xuanyu
# @Date: 2021-08-31 19:46:56
###

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
    kernel-devel
    bridge-utils
)

yum install ${packages[*]} -y
yum remove dnsmasq  virt -y