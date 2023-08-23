#!/bin/bash
###
# @Author: xuanyu
# @Date: 2021-08-31 17:25:47
###
set -eux
set -o pipefail

packages=(
    wget
    python-pip
    python-jinja2
    python-oauthlib
    python2-pyyaml
    python-requests
    python-jsonpatch
    python-markupsafe
    python-jsonschema
    python-six
    python-argpars
    cloud-utils-growpart
    dracut-modules-growroot
)
   # cloud-init-18.5

yum install ${packages[*]} -y
yum install -y cloud-init
dracut -f
