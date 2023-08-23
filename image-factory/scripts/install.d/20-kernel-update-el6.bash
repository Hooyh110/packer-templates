#!/usr/bin/env bash
packages=(
  kernel-3.10.0-123.6.el6.ksyun.x86_64
  kernel-headers-3.10.0-123.6.el6.ksyun.x86_64
  kernel-devel-3.10.0-123.6.el6.ksyun.x86_64
  kernel-firmware-3.10.0-123.6.el6.ksyun.x86_64
  kernel-debuginfo-3.10.0-123.6.el6.ksyun.x86_64
)
yum install -y ${packages[*]} --skip-broken

sed -i "s/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g" /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

reboot