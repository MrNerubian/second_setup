#!/bin/bash
#el7 set
#by:nerubian|奈幽
#使用方法：sh nerubian.sh new_hostname new_ip

#setup
#################################################################
#	yes = open
#	no  = close

#firewalld(yes|no)
flopen1=no
#firewalld chkconfig(yes|no)
flopen2=no
#SElinux(yes|no)
seopen=no


############################################################
#Am I root
if [ `id -u` -eq 0 ];then
	echo "Good lock for you!"
else
	echo "Error!You are not root!"
	exit
fi

#yum.repos.d backup
mkdir /root/yum-back -p
mv /etc/yum.repos.d/* /root/yum-back/
#make tuna.repo
cat > /etc/yum.repos.d/tuna.repo <<EOF
[base]
name=CentOS-$releasever - Base
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-$releasever - Updates
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

EOF
#remove cache
rm -rf /var/cache/yum &> /dev/null
yum clean all &> /dev/null

#hostanme set
hostnamectl set-hostname $1
echo HOSTANME：$(hostname)

#IP set
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.122.10
NETMASK=255.255.255.0
GATEWAY=192.168.122.1
DNS1=119.29.29.29
EOF
sed -i "/^IPADDR=/s/=.*/=$2/" /etc/sysconfig/network-scripts/ifcfg-eth0
cat /etc/sysconfig/network-scripts/ifcfg-e* |grep IPADDR

#hosts
cp -f /etc/hosts /etc/hosts.bak
head -2 /etc/hosts.bak > /etc/hosts
echo "$2 $1" >> /etc/hosts

#firewalld set
if [ $flopen1 = no ];then
	#close firewalld
	systemctl stop firewalld.service &> /dev/null
elif [ $flopen1 = yes ] ;then
	#open firewalld
	systemctl start firewalld.service &> /dev/null
fi

#firewalld chkconfig set
if [ $flopen2 = no ];then	
	#firewalld chkconfig open
	systemctl disable firewalld.service &> /dev/null
elif [ $flopen2 = yes ] ;then
	#firewalld chkconfig close
	systemctl enable firewalld.service &> /dev/null
fi


#selinux
if [ $seopen = yes ];then
	#open selinux
	sed -i '/^SELINUX=/s/=.*/=enforcing/' /etc/selinux/config
elif [ $seopen = no ] ;then
	#close selinux
	sed -i '/^SELINUX=/s/=.*/=disabled/' /etc/selinux/config
fi
