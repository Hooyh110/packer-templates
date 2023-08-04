#!/bin/bash
set -eux
set -o pipefail

export LC_ALL=C.UTF-8

DATA_PATH=/data/packages

if [[ ! -d "$DATA_PATH" ]]
then
    mkdir -p "$DATA_PATH"
fi

if ! mountpoint -q "$DATA_PATH"
then
    mount /dev/disk/by-label/penglai "$DATA_PATH"
fi
bash "$DATA_PATH"/houyi/packages/youchao-bootstrap/node-init.sh