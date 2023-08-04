#!/bin/bash
###
 # @Author: xuanyu
 # @Date: 2021-08-31 19:45:46
###

set -eux
set -o pipefail

sed -i 's/^#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/^GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config