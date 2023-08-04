#!/bin/bash
packages=(
   kernel-lt-5.4.116-1.el7.elrepo.x86_64
   kernel-lt-devel-5.4.116-1.el7.elrepo.x86_64
   kernel-lt-doc-5.4.116-1.el7.elrepo.noarch
   kernel-lt-headers-5.4.116-1.el7.elrepo.x86_64
   kernel-lt-tools-5.4.116-1.el7.elrepo.x86_64
   kernel-lt-tools-libs-5.4.116-1.el7.elrepo.x86_64
   kernel-lt-tools-libs-devel-5.4.116-1.el7.elrepo.x86_64

)
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-ml
yum install ${packages[*]} -y


grub2-set-default 0
reboot

