wget -c http://luna.galaxy.ksyun.com/galaxy/ks3/7/x86_64/kmod-megaraid_sas-06.813.05.00_el7.2-1.x86_64.rpm
rpm -ivh kmod-megaraid_sas-06.813.05.00_el7.2-1.x86_64.rpm --nodeps --force
wget -c http://luna.galaxy.ksyun.com/galaxy/base/7/x86_64/kmod-megaraid_sas-07.710.06.00_el7.6-1.x86_64.rpm
rpm -ivh kmod-megaraid_sas-07.710.06.00_el7.6-1.x86_64.rpm --nodeps --force

echo 'add_drivers+=" megaraid_sas "' > /etc/dracut.conf.d/megaraid_sas.conf
dracut -f
