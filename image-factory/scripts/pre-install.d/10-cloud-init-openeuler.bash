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
    python-requests
    python-jsonpatch
    python-markupsafe
    python-jsonschema
    python-six
    cloud-init
    vim
    libcurl-devel
)
   # cloud-init-18.5

yum install ${packages[*]} -y
dracut -f
