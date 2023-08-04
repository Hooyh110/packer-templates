#!/usr/bin/env bash

chmod 755 /etc/rc.d/rc.local
echo "bash /usr/local/sshd.sh" >> /etc/rc.local