#!/bin/bash
###
# @Author: xuanyu
# @Date: 2021-08-31 17:20:32
###
set -eux
set -o pipefail
rm -rf /etc/yum.repos.d/Centos*.repo

yum clean all
#sleep 180m
#yum install -y epel-release


