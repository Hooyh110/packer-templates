#!/bin/bash
packages=(
   kernel-3.10.0-957.el7.x86_64
   kernel-devel-3.10.0-957.el7.x86_64
   kernel-headers-3.10.0-957.el7.x86_64
   kernel-debuginfo-3.10.0-957.el7.x86_64
)
yum install ${packages[*]} -y

grub2-set-default 0
reboot

