#!/bin/bash
##设置字符集
export LANG=zh_CN.UTF8

##创建常用服务用目录
/bin/mkdir -p /app/zabbix
/bin/mkdir -p /log/zabbix
/bin/mkdir -p /bak/zabbix

##rpm安装zabbix函数
function zabbix_rpm()
{
    #download
    /usr/bin/wget http://10.18.12.93:9000/server/zabbix/unixODBC-2.2.14-14.el6.x86_64.rpm --directory-prefix=/app/zabbix
    /usr/bin/wget http://10.18.12.93:9000/server/zabbix/zabbix-agent-3.0.3-1.el6.x86_64.rpm --directory-prefix=/app/zabbix
    #install
    /bin/rpm -ivh /app/zabbix/unixODBC-2.2.14-14.el6.x86_64.rpm
    /bin/rpm -ivh /app/zabbix/zabbix-agent-3.0.3-1.el6.x86_64.rpm
}

##yum安装zabbix函数
function zabbix_yum()
{
    /usr/bin/yum -y install zabbix-agent
}

if [ -f "/etc/yum.repos.d/local.repo" ];then
    zabbix_yum
else
    zabbix_rpm
fi

##获取服务器IP
host_ip=`/sbin/ifconfig | grep 'inet addr:'|awk 'NR==1{print $2}'|awk -F: '{print $2}'`
active_ip=`echo $host_ip|sed 's/[0-9]\{1,3\}$/93/'`
#active_ip="10.16.12.93"


#update zabbix_agentd.conf
/bin/mv /etc/zabbix/zabbix_agentd.conf /bak/zabbix/
/usr/bin/wget http://10.18.12.93:9000/server/zabbix/conf/zabbix_agentd.conf --directory-prefix=/etc/zabbix/
/bin/sed -i '/^Hostname=/s/^.*$/Hostname='$host_ip'/g' /etc/zabbix/zabbix_agentd.conf
/bin/sed -i '/^ServerActive=/s/^.*$/ServerActive='$active_ip'/g' /etc/zabbix/zabbix_agentd.conf
/bin/echo "zabbix    ALL=(ALL)    NOPASSWD:ALL"  >> /etc/sudoers
/bin/mkdir -p /etc/zabbix/zabbix_agentd.d/libexec/


#into rc.local
/bin/echo "/etc/init.d/zabbix-agent start" >> /etc/rc.d/rc.local

#restart zabbix-agent
/etc/init.d/zabbix-agent restart


