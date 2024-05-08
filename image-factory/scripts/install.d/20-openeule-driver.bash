#!/bin/bash
set -eux
set -o pipefail

cd /root/
tar xf driver.tar.gz
cd RPMS
yum install *.rpm -y

echo 'add_drivers+=" megaraid_sas "' > /etc/dracut.conf.d/megaraid_sas.conf
dracut --force
