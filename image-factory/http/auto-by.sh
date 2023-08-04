#!/bin/bash
systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl stop NetworkManager
systemctl disable NetworkManager


#将所有网卡名称复制到文本中
ip a |awk '{print $2}'|grep "em"|awk -F ':' '{print $1}' > netname.txt
#赋予变量

net1=`awk -F ' ' '{print $1}' netname.txt | awk 'NR==1'`
mac1=`ip a |grep "ether" | awk '{print $2}'|awk 'NR==1'`

net2=`awk -F ' ' '{print $1}' netname.txt | awk 'NR==2'`
mac2=`ip a |grep "ether" | awk '{print $2}'|awk 'NR==2'`

net3=`awk -F ' ' '{print $1}' netname.txt | awk 'NR==3'`
mac3=`ip a |grep "ether" | awk '{print $2}'|awk 'NR==3'`

net4=`awk -F ' ' '{print $1}' netname.txt | awk 'NR==4'`
mac4=`ip a |grep "ether" | awk '{print $2}'|awk 'NR==4'`

echo -ne "
$net1,$mac1
$net2,$mac2
$net3,$mac3
$net4,$mac4
" >> n-m.txt

#依次校准网卡的名称及mac地址
m1=`cat n-m.txt |grep 'em1'|awk -F ',' '{print $2}'`
m2=`cat n-m.txt |grep 'em2'|awk -F ',' '{print $2}'`
m3=`cat n-m.txt |grep 'em3'|awk -F ',' '{print $2}'`
m4=`cat n-m.txt |grep 'em4'|awk -F ',' '{print $2}'`

#根据SN获取网卡配置信息
SN=`dmidecode -s system-serial-number 2>/dev/null | awk "/^[^#]/ { print $1 }"`
NAME=`cat /home/message.txt |grep $SN |awk -F ',' '{print $2}'`
IP=`cat /home/message.txt |grep $SN |awk -F ',' '{print $3}'`
MASK=`cat /home/message.txt |grep $SN |awk -F ',' '{print $4}'`
GATEWAY=`cat /home/message.txt |grep $SN |awk -F ',' '{print $5}'`

#将校准过的mac地址填写到需要填写mac地址的文件中
#写到网卡名与mac地址绑定的规则文件中

cat > /etc/udev/rules.d/70-persistent-net.rules <<EOF
SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{address}=="$m1",ATTR{type}=="1",KERNEL=="eth*",NAME="eth0"
SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{address}=="$m2",ATTR{type}=="1",KERNEL=="eth*",NAME="eth1"
SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{address}=="$m3",ATTR{type}=="1",KERNEL=="eth*",NAME="eth2"
SUBSYSTEM=="net",ACTION=="add",DRIVERS=="?*",ATTR{address}=="$m4",ATTR{type}=="1",KERNEL=="eth*",NAME="eth3"
EOF

#写到网卡配置文件中
cd /etc/sysconfig/network-scripts/
#更名
mv ifcfg-em1 ifcfg-eth0
mv ifcfg-em2 ifcfg-eth1
mv ifcfg-em3 ifcfg-eth2
mv ifcfg-em4 ifcfg-eth3
sed -i 's/em1/eth0/g' ifcfg-eth0
sed -i 's/em2/eth1/g' ifcfg-eth1
sed -i 's/em3/eth2/g' ifcfg-eth2
sed -i 's/em4/eth3/g' ifcfg-eth3

mv ifcfg-eth0{,.bak}
mv ifcfg-eth1{,.bak}

echo -ne "TYPE=Ethernet
NAME=eth0
DEVICE=eth0
HWADDR=$m1
ONBOOT=yes
MASTER=bond0
SLAVE=yes
" >> /etc/sysconfig/network-scripts/ifcfg-eth0

echo -ne "TYPE=Ethernet
NAME=eth1
DEVICE=eth1
HWADDR=$m2
ONBOOT=yes
MASTER=bond0
SLAVE=yes
" >> /etc/sysconfig/network-scripts/ifcfg-eth1

echo "HWADDR=$m3" >> /etc/sysconfig/network-scripts/ifcfg-eth2
echo "HWADDR=$m4" >> /etc/sysconfig/network-scripts/ifcfg-eth3

cat > /etc/sysconfig/network-scripts/ifcfg-bond0 <<EOF
DEVICE=bond0
BONDING_OPTS="mode=0 miimon=100"
TYPE=Bond
BONDING_MASTER=yes
BOOTPROTO=static
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=no
NAME=bond0
IPADDR=$IP
NETMASK=$MASK
GATEWAY=$GATEWAY
ONBOOT=yes
EOF

modprobe --first-time bonding
######重启网卡####
sed -i 's/ONBOOT=yes/ONBOOT=no/g' ifcfg-eth2

##设置主机名
sed -i 's/localhost.localdomain/'$NAME'/g' /etc/hostname
