#!/bin/bash
packages=(
   kernel-4.18.0-80.11.3.0.el7.ksyun.x86_64
   kernel-tools-4.18.0-80.11.3.0.el7.ksyun.x86_64
   kernel-devel-4.18.0-80.11.3.0.el7.ksyun.x86_64
   kernel-headers-4.18.0-80.11.3.0.el7.ksyun.x86_64
)
#yum update
#yum remove -y kernel-tools-libs-4.18.0-305.0.0.0.el7.ksyun.x86_64
yum install ${packages[*]} -y --skip-broken
grub2-set-default 0
reboot

