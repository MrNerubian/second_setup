#!/bin/bash
#el6 second set

#主机名设置

sed -i "/^HOSTNAME=/s/=.*/=$1/" /etc/sysconfig/network
echo 当前主机名称为：$(cat /etc/sysconfig/network|grep HOSTNAME=|cut -d'=' -f2)

#IP调整
sed -i "/^IPADDR=/s/=.*/=$2/" /etc/sysconfig/network-scripts/ifcfg-e*
echo "当前主机IP为：$(cat /etc/sysconfig/network-scripts/ifcfg-e* |grep IPADDR|cut -d'=' -f2)"
rm -f /etc/udev/rules.d/70-persistent-net.rules

#hosts文件重绑
cp -f /etc/hosts /etc/hosts.bak
head -2 /etc/hosts.bak > /etc/hosts
echo "$1 $2" >> /etc/hosts
