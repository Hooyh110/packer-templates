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
    tmp_dir=$(mktemp -d)
    cd /usr/local
    #sleep 300m
    wget http://luna.galaxy.ksyun.com/sources/drivers/i40e/i40e-2.20.12.tar.gz
    #tar -xf MLNX_EN_SRC-4.3-3.0.2.1.tgz
    sleep 5m
    #cd MLNX_EN_SRC-4.3-3.0.2.1
    tar xf i40e-2.20.12.tar.gz
    cd i40e-2.20.12
    cd src
    sed -i '62i\        /usr/src/kernels/5.4.116-1.el7.elrepo.x86_64 \\' common.mk
    make
    make install
    #./install.pl --all
    depmod -a
    modprobe i40e
    dracut --force
    cd /usr/local
    wget http://luna.galaxy.ksyun.com/sources/drivers/ixgbe/ixgbe-5.18.13.tar.gz
    tar xf ixgbe-5.18.13.tar.gz
    cd ixgbe-5.18.13/src
    make
    make install 
    depmod -a
    modprobe ixgbe
    dracut --force

}

driver
