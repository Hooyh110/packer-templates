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
#yum update
#yum remove -y kernel-tools-libs-4.18.0-305.0.0.0.el7.ksyun.x86_64
yum install ${packages[*]} -y --skip-broken
grub2-set-default 0
reboot

