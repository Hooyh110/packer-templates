#!/bin/bash
###
# @Author: xuanyu
# @Date: 2021-09-26 11:15:59
###
#sleep 30m
set -eux
set -o pipefail
driver_name=kmod-megaraid_sas
pkg_version=07.724.02.00
minor_version=7.21
# pkg_version=07.717.02.00
# minor_version=7.17

kernel_version=$(uname -r | grep -m 1 -o '^[0-9\.-]*[0-9]')
centos_version=$(grep -o '[0-9\.]*' /etc/centos-release | awk -F \. '{print $1}')
pkg_release=${kernel_version/-/_}.el${centos_version}

function driver() {
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir"
    wget http://luna.galaxy.ksyun.com/sources/drivers/megaraid_sas/MR_LINUX_DRIVER_${minor_version}-${pkg_version}-1.tgz
    tar -xf MR_LINUX_DRIVER_${minor_version}-${pkg_version}-1.tgz
    cd MR_LINUX_DRIVER_${minor_version}-${pkg_version}-1
    rpm -ivh kmod_srpm/kmod-megaraid_sas-${pkg_version}-1.src.rpm
    yum install -y rpm-build make gcc kernel-devel-$(uname -r) elfutils-libelf-devel

    #yum install -y rpm-build make gcc kernel-devel elfutils-libelf-devel
    sed -i '/kmod_rpm_release/s/1/'${pkg_release}'/' /root/rpmbuild/SPECS/megaraid_sas.spec
    rpmbuild -ba --define "debug_package %{nil}" /root/rpmbuild/SPECS/megaraid_sas.spec
    yum install -y /root/rpmbuild/RPMS/x86_64/kmod-megaraid_sas-${pkg_version}-${pkg_release}.$(uname -i).rpm

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

case $centos_version in
"6" | "7")
    pkg_num=$(yum list --showduplicates | { grep ${driver_name} || test $? = 1; } | { grep -c "${pkg_version}-${pkg_release}" || test $? = 1; })
    if [ "$pkg_num" -ge "1" ]; then
        yum install -y "${driver_name}-${pkg_version}-${pkg_release}"
    else
        driver
    fi
    ;;
esac
yum install -y kmod-megaraid_sas-07.710.06.00-3.10.0_862.el7.x86_64

echo 'add_drivers+=" megaraid_sas "' > /etc/dracut.conf.d/megaraid_sas.conf
dracut -f
