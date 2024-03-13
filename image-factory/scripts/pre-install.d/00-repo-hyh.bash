#!/bin/bash
###
# @Author: xuanyu
# @Date: 2021-08-31 17:20:32
###
set -eux
set -o pipefail
rm -rf /etc/yum.repos.d/Centos*.repo
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/*

sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/*
yum clean all
#yum install -y epel-release


