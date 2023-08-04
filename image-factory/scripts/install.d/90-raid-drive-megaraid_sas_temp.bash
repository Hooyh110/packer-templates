#!/bin/bash
###
# @Author: xuanyu
# @Date: 2021-09-26 11:15:59
###

set -eux
set -o pipefail

kernel_version=$(uname -r | grep -m 1 -o '^[0-9\.-]*[0-9]')
centos_version=$(grep -o '[0-9\.]*' /etc/centos-release | awk -F \. '{print $1}')
driver_name=kmod-mpt3sas
pkg_version=26.00.00.00
pkg_release=${kernel_version/-/_}.el${centos_version}

yum install wget -y
function driver() {
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    wget http://luna.galaxy.ksyun.com/sources/drivers/mpt3sas/mpt3sas-${pkg_version}-1.src.rpm
    rpm -ivh mpt3sas-${pkg_version}-1.src.rpm
    yum install -y rpm-build make gcc kernel-devel-$(uname -r)
    #yum install -y rpm-build make gcc kernel-devel
    sed -i '/Release/s/1/'${pkg_release}'/' /root/rpmbuild/SPECS/mpt3sas.spec
    rpmbuild -ba --define "debug_package %{nil}" /root/rpmbuild/SPECS/mpt3sas.spec
    rpm -ivh /root/rpmbuild/RPMS/$(uname -i)/kmod-mpt3sas-${pkg_version}-${pkg_release}.$(uname -i).rpm  --nodeps --force
    #parted /dev/sda -s -- mklabel gpt
    # cd && rm -rf $tmp_dir /root/rpmbuild/
}

function remove_other_version() {
    num=$(rpm -qa | { grep -c ${driver_name} || test $? = 1; })
    if [ "$num" -ge "1" ]; then
        version=$(rpm -qi ${driver_name} | awk '/Version/{print $3}')
        release=$(rpm -qi ${driver_name} | awk '/Release/{print $3}')
        if [ "$version" != "$pkg_version" ] || [ "$release" != "$pkg_release" ]; then
            yum remove ${driver_name} -y
        fi
    fi
}

remove_other_version
        driver
echo 'add_drivers+=" mpt3sas "' > /etc/dracut.conf.d/mpt3sas.conf
dracut -f
