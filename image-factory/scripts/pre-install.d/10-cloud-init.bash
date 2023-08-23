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
    python-argparse
    cloud-init
    cloud-utils-growpart
    dracut-modules-growroot
)
   # cloud-init-18.5
sleep 30m
yum install ${packages[*]} -y
dracut -f
