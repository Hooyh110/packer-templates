
#!/bin/bash
cat > /etc/sysconfig/network-scripts/ifcfg-bond1 << EOF
DEVICE="bond1"
ONBOOT=yes
BOOTPROTO=dhcp
USERCTL=no
BONDING_OPTS="mode=802.3ad xmit_hash_policy=layer2+3 miimon=100"
EOF

cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER="bond1"
SLAVE=yes
EOF

cat > /etc/sysconfig/network-scripts/ifcfg-eth1 << EOF
DEVICE="eth1"
ONBOOT=yes
BOOTPROTO=none
USERCTL=no
MASTER="bond1"
SLAVE=yes
EOF

