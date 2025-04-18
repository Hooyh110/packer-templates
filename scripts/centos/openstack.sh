#!/bin/bash -eux

if [ $(uname -m)=="ppc64" -o $(uname -m)=="ppc64le" ]
  then
    yum -y install ppc64-diag
fi

yum -y install --skip-broken  dracut-modules-growroot \
  cloud-utils-growpart gdisk
dracut -f

if [ -e /boot/grub/grub.conf ] ; then
  sed -i -e 's/rhgb.*/console=ttyS0,115200n8 console=tty0 quiet/' /boot/grub/grub.conf
  sed -i -e 's/^timeout=.*/timeout=0/' /boot/grub/grub.conf
  cd /boot
  ln -s boot .
elif [ -e /etc/default/grub ] ; then
  # output bootup to serial
  sed -i -e \
    's/GRUB_CMDLINE_LINUX=\"\(.*\)/GRUB_CMDLINE_LINUX=\"console=ttyS0,115200n8 console=tty0 \1/g' \
    /etc/default/grub
  # No timeout for grub menu
  sed -i -e 's/^GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/' /etc/default/grub
  # No fancy boot screen
  grep -q rhgb /etc/default/grub && sed -e 's/rhgb //' /etc/default/grub
  # Write out the config
  if [ $(uname -m) == "aarch64" ] ; then
    grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
  else
    grub2-mkconfig -o /boot/grub2/grub.cfg
  fi
fi

# Ensure that the cloud-init user is correct
sed -i -e 's/name: fedora/name: centos/' /etc/cloud/cloud.cfg
sed -i -e 's/name: cloud-user/name: centos/' /etc/cloud/cloud.cfg
sed -i -e 's/Fedora Cloud User/CentOS Cloud User/' /etc/cloud/cloud.cfg
sed -i -e 's/Cloud User/CentOS Cloud User/' /etc/cloud/cloud.cfg
sed -i -e 's/distro: fedora/distro: rhel/' /etc/cloud/cloud.cfg

# Ensure that cloud-init starts before sshd
if [[ -e /usr/lib/systemd/system/cloud-init.service && ! -e /etc/yum.repos.d/CentOS-AppStream.repo ]] ; then
  FILE=/usr/lib/systemd/system/cloud-init.service
  sed -i '/^Wants/s/$/ sshd.service/' $FILE
  grep -q Before $FILE && sed -i '/Before/s/$/ sshd.service/' $FILE ||  sed -i '/\[Unit\]/aBefore=sshd.service' $FILE
fi
