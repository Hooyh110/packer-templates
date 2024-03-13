#!/usr/bin/env bash
packages=(
  kernel-3.10.0-123.6.el6.ksyun.x86_64
  kernel-headers-3.10.0-123.6.el6.ksyun.x86_64
  kernel-devel-3.10.0-123.6.el6.ksyun.x86_64
  kernel-firmware-3.10.0-123.6.el6.ksyun.x86_64
  kernel-debuginfo-3.10.0-123.6.el6.ksyun.x86_64
)
yum downgrade -y ${packages[*]} --skip-broken
grub-set-default 0
reboot