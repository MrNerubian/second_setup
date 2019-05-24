#!/bin/bash
#el7 second set

#主机名设置
hostnamectl set-hostname $1
echo 当前主机名称为：$(hostname)

#IP调整
sed -i "/^IPADDR=/s/=.*/=$2/" /etc/sysconfig/network-scripts/ifcfg-e*
cat /etc/sysconfig/network-scripts/ifcfg-e* |grep IPADDR

#hosts文件重绑
cp -f /etc/hosts /etc/hosts.bak
head -2 /etc/hosts.bak > /etc/hosts
echo "$1 $2" >> /etc/hosts
