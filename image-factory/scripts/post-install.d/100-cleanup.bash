#!/bin/bash
###
 # @Author: xuanyu
 # @Date: 2021-08-31 18:11:54
###

set -eux
set -o pipefail

# 清理用户登录记录
echo > /var/log/wtmp
echo > /var/log/btmp

# 清理 ssh 主机秘钥
rm -rf /etc/ssh/ssh_host_*

rm -rf /etc/sysconfig/network-scripts/ifcfg-eth0

rm -rf /var/lib/dhclient/*.lease

rm -rf /tmp/*

yum clean all
rm -rf /var/cache/yum/
rm -rf /var/cache/dnf/

cloud-init clean -l -s

history -w
echo > /root/.bash_history
history -c
