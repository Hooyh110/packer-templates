#!/bin/bash
set -eux
set -o pipefail

cd /root/
tar xf driver.tar.gz
cd RPMS
yum install *.rpm -y
dracut --force
