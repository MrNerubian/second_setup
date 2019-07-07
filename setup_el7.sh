#!/bin/bash
#el7 setup v1.1
#by:nerubian|奈幽
#Usage: sh nerubian.sh [new_hostname] [new_ip]

#Parameter setting area/参数设置区域
####################################################################
#	yes = open
#	no  = close

#firewalld(yes|no)
flopen1=no
#firewalld chkconfig(yes|no)
flopen2=no
#SElinux(yes|no)
seopen=no
#network name
netname=eth0
#getwark
getw=192.168.122.1

#Status detection area/状态检测区域
####################################################################
echo '============================================================='
echo
echo -e "\033[32mUsage: sh nerubian.sh [new_hostname] [new_ip]\033[0m"
echo

#$1 and $2 Non-empty Detection
if [ $1 -z ];then
	echo 'Error! Parameter is null! Please reenter the command!'
	echo 'Usage: sh nerubian.sh [new_hostname] [new_ip]'
	exit
elif [ $2 -z ];then
	echo 'Error! IP is null! Please reenter the command!'
	echo 'Usage: sh nerubian.sh [new_hostname] [new_ip]'
	exit
fi

#Am I root
if [ `id -u` -eq 0 ];then
	echo "Hello root!"
else
	echo "Error! You are not root! You can't use this！"
	exit
fi

#Command execution area/命令执行区域
####################################################################

#hostanme set
hostnamectl set-hostname $1
echo HOSTANME : $(hostname)

#IP set
cat > /etc/sysconfig/network-scripts/ifcfg-$netname <<EOF
DEVICE=$netname
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.122.10
NETMASK=255.255.255.0
GATEWAY=192.168.122.1
DNS1=119.29.29.29
EOF

#echo IP
sed -i "/^IPADDR=/s/=.*/=$2/" /etc/sysconfig/network-scripts/ifcfg-$netname
ipin=`awk -F= '$1=="IPADDR" {print $2}' /etc/sysconfig/network-scripts/ifcfg-$netname`
echo The IP to ifcfg-$netname is: $ipin

#echo GATEWAY
sed -i "/^GATEWAY=/s/=.*/=$getw/" /etc/sysconfig/network-scripts/ifcfg-$netname
ipin2=`awk -F= '$1=="GATEWAY" {print $2}' /etc/sysconfig/network-scripts/ifcfg-$netname`
echo The GATEWAY to ifcfg-$netname is: $ipin2

#hosts set
cp -f /etc/hosts /etc/hosts.bak
head -2 /etc/hosts.bak > /etc/hosts
echo "$2 $1" >> /etc/hosts

#yum.repos.d backup
mkdir /root/yum-back -p
mv /etc/yum.repos.d/* /root/yum-back/

#touch tuna.repo
cat > /etc/yum.repos.d/tuna.repo <<EOF
[base]
name=CentOS-\$releasever - Base
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-\$releasever - Updates
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-\$releasever - Extras
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-\$releasever - Plus
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

EOF

#tuna.repo backup
if [ ! -d "/root/yum-back/tuna.repo" ];then
	cp /root/yum-back/tuna.repo /etc/yum.repos.d/
fi
	
#remove yum cache
rm -rf /var/cache/yum &> /dev/null
yum clean all &> /dev/null

#firewalld set
if [ $flopen1 = no ];then
	#close firewalld
	systemctl stop firewalld.service &> /dev/null
	echo 'firewalld  :  stop'
elif [ $flopen1 = yes ] ;then
	#open firewalld
	systemctl start firewalld.service &> /dev/null
	echo 'firewalld  : start'
fi

#firewalld chkconfig set
if [ $flopen2 = no ];then	
	#firewalld chkconfig close
	systemctl disable firewalld.service &> /dev/null
	echo 'firewalld chkconfig  :  disable'
elif [ $flopen2 = yes ] ;then
	#firewalld chkconfig open
	systemctl enable firewalld.service &> /dev/null
	echo 'firewalld chkconfig  :  enable '
fi


#selinux set
if [ $seopen = yes ];then
	#open selinux
	sed -i '/^SELINUX=/s/=.*/=enforcing/' /etc/selinux/config
	echo 'SELINUX : enforcing'
elif [ $seopen = no ] ;then
	#close selinux
	sed -i '/^SELINUX=/s/=.*/=disabled/' /etc/selinux/config
	echo 'SELINUX : disabled'
fi

#reboot
echo
echo '============================================================='
while true
do
	echo "Whether to restart the computer(yes|no)" 
	read -p ": " restart1
	if [ $restart1 = no -o $restart1 = NO -o $restart1 = n -o $restart1 = N ];then	
		echo 'Thank you for using,Bye !'
		break
	elif [ $restart1 = yes -o $restart1 = YES -o $restart1 = y -o $restart1 = Y ] ;then
		echo 'Thank you for using,Bye !'
		reboot
	else
		echo -e "\033[31m Error! \033[0m \033[32m Usage:[ yes,YES,y,Y | no,NO,n,N ]\033[0m"
		continue
	fi
done
echo '============================================================='

#restart network
systemctl restart network
ipnew=`ip a|grep eth0$|awk -F'[ /]+' '{print $3}'`
echo The current IP is $ipnew
