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
    #cd "$tmp_dir"
    #wget http://luna.galaxy.ksyun.com/sources/drivers/i40e/i40e-2.16.11.tar.gz
    #tar -xf MLNX_EN_SRC-4.3-3.0.2.1.tgz
    #sleep 30m
    #cd MLNX_EN_SRC-4.3-3.0.2.1
    cd /usr/local/
    tar xf i40e-2.1.29u.tar.gz
    cd i40e-2.1.29u
    cd src
    make
    make install
    #./install.pl --all

    
}

driver
