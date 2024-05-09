#!/bin/bash
###
# @Author: huyuhao
# @Date: 2024-05-07 17:20:32
###
set -eux
set -o pipefail

yum clean all
yum list
yum install tar -y