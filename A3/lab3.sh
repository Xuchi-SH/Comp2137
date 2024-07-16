#!/bin/bash
# This script runs the configure-host.sh script from the current directory to modify 2 servers and update the local /etc/hosts file

scp configure-host.sh remoteadmin@server1-mgmt:/root
ssh remoteadmin@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4

name1=$(ssh remoteadmin@server1-mgmt --  grep loghost /etc/hostname)
name2=$(ssh remoteadmin@server1-mgmt --  hostname)
name3=$(ssh remoteadmin@server1-mgmt --  grep loghost /etc/hosts|grep 192.168.16.3)
ip1=$(ssh remoteadmin@server1-mgmt --  ip a | grep 192.168.16.3)
ip2=$(ssh remoteadmin@server1-mgmt --  grep 192.168.16.4 /etc/hosts|grep webhost)

echo "===================================Server1 Check============================================"
echo "name1: $name1  name2: $name2"
[[ -n "$name1" ]] && [[ "$name2" -eq "loghost" ]] && echo "hostname is right" || echo "hostname is wrong"
echo "name3: $name3"
[[ -n "$name3" ]] && echo "/etc/hosts is right" || echo "/etc/hosts is wrong"
echo "ip1: $ip1"
[[ -n "$ip1" ]] && echo "system ip address is right" || echo "system ip address in /etc/hostname is wrong"
echo "ip2: $ip2"
[[ -n "$ip2" ]] && echo "host entry in /etc/hosts is right" || echo "host entry  in /etc/hosts is wrong"
echo "check server1 finished"
echo
echo


scp configure-host.sh remoteadmin@server2-mgmt:/root
ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3

name1=$(ssh remoteadmin@server2-mgmt --  grep webhost /etc/hostname)
name2=$(ssh remoteadmin@server2-mgmt --  hostname)
name3=$(ssh remoteadmin@server2-mgmt --  grep webhost /etc/hosts|grep 192.168.16.4)
ip1=$(ssh remoteadmin@server2-mgmt --  ip a | grep 192.168.16.4)
ip2=$(ssh remoteadmin@server2-mgmt --  grep 192.168.16.3 /etc/hosts|grep loghost)

echo "===================================Server2 Check============================================"
echo "name1: $name1  name2: $name2"
[[ -n "$name1" ]] && [[ "$name2" -eq "webhost" ]] && echo "hostname is right" || echo "hostname is wrong"
echo "name2: $name2"
[[ -n "$name3" ]] && echo "/etc/hosts is right" || echo "/etc/hosts is wrong"
echo "ip1: $ip1"
[[ -n "$ip1" ]] && echo "system ip address is right" || echo "system ip address in /etc/hostname is wrong"
echo "ip2: $ip2"
[[ -n "$ip2" ]] && echo "host entry in /etc/hosts is right" || echo "host entry  in /etc/hosts is wrong"
echo "check server2 finished"

#./configure-host.sh -hostentry loghost 192.168.16.3
#./configure-host.sh -hostentry webhost 192.168.16.4
