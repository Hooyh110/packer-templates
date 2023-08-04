#!/bin/bash
###
# @Author: yuhao
# @Date: 2023-04-24 11:51:59
###
#sleep 30m
set -eux
set -o pipefail
driver_name=hpssacli
pkg_version=2.0
minor_version=22.0

kernel_version=$(uname -r | grep -m 1 -o '^[0-9\.-]*[0-9]')
centos_version=$(grep -o '[0-9\.]*' /etc/centos-release | awk -F \. '{print $1}')
pkg_release=${kernel_version/-/_}.el${centos_version}

function driver() {
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    wget http://luna.galaxy.ksyun.com/sources/drivers/megaraid_sas/hpssacli-2.0-22.0.x86_64.tar.gz
    tar xf hpssacli-2.0-22.0.x86_64.tar.gz
    rpm -ivh hpssacli-2.0-22.0.x86_64.rpm
}

driver

echo 'add_drivers+=" megaraid_sas "' > /etc/dracut.conf.d/megaraid_sas.conf
dracut -f
