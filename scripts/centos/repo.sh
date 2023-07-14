#!/usr/bin/env bash
set -eux
set -o pipefail
rm -rf /etc/yum.repos.d/Centos*.repo
yum clean all