#!/bin/bash
###
# @Author: xuanyu
# @Date: 2021-08-31 17:20:32
###
set -eux
set -o pipefail

sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://mirror.centos.org|baseurl=http://luna.galaxy.ksyun.com|g' \
    -i.bak /etc/yum.repos.d/CentOS-*.repo

yum install -y epel-release

sed -e 's|^metalink=|#metalink=|' \
    -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://download.fedoraproject.org/pub|baseurl=http://luna.galaxy.ksyun.com|g' \
    -e 's|^#baseurl=https://download.example/pub|baseurl=http://luna.galaxy.ksyun.com|g' \
    -i.bak /etc/yum.repos.d/epel*.repo
