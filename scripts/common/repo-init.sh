#!/bin/bash
###
# @Author: huyuhao
# @Date: 2023-08-25 17:20:32
###
set -eux
set -o pipefail
rm -rf /etc/yum.repos.d/*.repo
yum clean all
#yum install -y epel-release


