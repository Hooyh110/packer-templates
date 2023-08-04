#!/bin/bash
###
# @Author: xuanyu
# @Date: 2021-09-26 11:15:59
###

set -eux
set -o pipefail


function driver() {
    yum install gcc kernel-devel-$(uname -r) kernel-headers-$(uname -r) -y
     rpm -qa    kernel-devel  kernel-headers
    #tmp_dir=$(mktemp -d)
    cd /usr/local/
    wget http://luna.galaxy.ksyun.com/sources/drivers/ixgbe/ixgbe-5.8.1.tar.gz
    #tar -xf MLNX_EN_SRC-4.3-3.0.2.1.tgz
    #sleep 30m
    #cd MLNX_EN_SRC-4.3-3.0.2.1
    tar xf ixgbe-5.8.1.tar.gz
    cd ixgbe-5.8.1
    cd src
    sed -i '62i\        /usr/src/kernels/3.10.0-957.el7.x86_64 \\' common.mk
    make
    make install
    depmod -a
    modprobe ixgbe
    dracut --force
    reboot
    sleep 60s
}

driver
