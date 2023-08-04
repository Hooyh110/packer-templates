#!/bin/bash
###
# @Author: xuanyu
# @Date: 2021-09-26 11:15:59
###

set -eux
set -o pipefail


function driver() {
    yum install lsof redhat-rpm-config rpm-build libxml2-python gcc kernel-devel-$(uname -r) -y
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    wget http://luna.galaxy.ksyun.com/sources/drivers/mlnx/MLNX_EN_SRC-4.3-3.0.2.1.tgz
    tar -xf MLNX_EN_SRC-4.3-3.0.2.1.tgz
    cd MLNX_EN_SRC-4.3-3.0.2.1
    ./install.pl --all

    cd && rm -rf "$tmp_dir"
}

driver