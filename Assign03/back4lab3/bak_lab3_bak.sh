#!/bin/bash
#Chi Xu 16-Juyl-2024
#This script runs the configure-host.sh script from the current directory to modify 2 servers and update the local /etc/hosts file

# Parse command-line arguments
param1=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        -verbose)
#           VERBOSE=true
            echo "verbose is true"
            param1=" -verbose"
            ;;
        *)
            echo "wrong inputs"
            exit 1
            ;;
    esac
    shift
done


#eval "ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3 $param1"


echo "===================================Modify Server1============================================"
scp configure-host.sh remoteadmin@server1-mgmt:/root
eval "ssh remoteadmin@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4  $param1"

name1=$(ssh remoteadmin@server1-mgmt --  grep loghost /etc/hostname)
name2=$(ssh remoteadmin@server1-mgmt --  hostname)
name3=$(ssh remoteadmin@server1-mgmt --  grep loghost /etc/hosts|grep 192.168.16.3)
ip1=$(ssh remoteadmin@server1-mgmt --  ip a | grep 192.168.16.3)
ip2=$(ssh remoteadmin@server1-mgmt --  grep 192.168.16.4 /etc/hosts|grep webhost)

echo "===================================Server1 Check============================================"
#echo "name1: $name1  name2: $name2"
#echo "name3: $name3"
#echo "ip1: $ip1"
#echo "ip2: $ip2"
#echo "check server1 finished"
[[ -n "$name1" ]] && [[ "$name2" -eq "loghost" ]] && echo "hostname is right" || echo "hostname is wrong"
[[ -n "$name3" ]] && echo "/etc/hosts is right" || echo "/etc/hosts is wrong"
[[ -n "$ip1" ]] && echo "system ip address is right" || echo "system ip address in /etc/hostname is wrong"
[[ -n "$ip2" ]] && echo "host entry in /etc/hosts is right" || echo "host entry  in /etc/hosts is wrong"


echo
echo

echo "===================================Modify Server2============================================"
scp configure-host.sh remoteadmin@server2-mgmt:/root
eval "ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3  $param1"

name1=$(ssh remoteadmin@server2-mgmt --  grep webhost /etc/hostname)
name2=$(ssh remoteadmin@server2-mgmt --  hostname)
name3=$(ssh remoteadmin@server2-mgmt --  grep webhost /etc/hosts|grep 192.168.16.4)
ip1=$(ssh remoteadmin@server2-mgmt --  ip a | grep 192.168.16.4)
ip2=$(ssh remoteadmin@server2-mgmt --  grep 192.168.16.3 /etc/hosts|grep loghost)

echo "===================================Server2 Check============================================"
#echo "name1: $name1  name2: $name2"
#echo "name3: $name3"
#echo "ip1: $ip1"
#echo "ip2: $ip2"
#echo "check server2 finished"

[[ -n "$name1" ]] && [[ "$name2" -eq "webhost" ]] && echo "hostname is right" || echo "hostname is wrong"
[[ -n "$name3" ]] && echo "/etc/hosts is right" || echo "/etc/hosts is wrong"
[[ -n "$ip1" ]] && echo "system ip address is right" || echo "system ip address in /etc/hostname is wrong"
[[ -n "$ip2" ]] && echo "host entry in /etc/hosts is right" || echo "host entry  in /etc/hosts is wrong"

echo
echo

echo "===================================Modify Host============================================"
eval "./configure-host.sh -hostentry loghost 192.168.16.3  $param1"
eval "./configure-host.sh -hostentry webhost 192.168.16.4  $param1"

echo "===================================Host Check============================================"
desired_name="loghost"
desired_ip="192.168.16.3"
entry=$(grep -E "^\s*$desired_ip\s+$desired_name(\s|$)" /etc/hosts)
#echo "$entry"
[[ -n "$entry" ]] && echo "/etc/hosts contains loghost 192.168.16.3" || echo "/etc/hosts does not contain loghost 192.168.16.3"

desired_name="webhost"
desired_ip="192.168.16.4"
entry=$(grep -E "^\s*$desired_ip\s+$desired_name(\s|$)" /etc/hosts)
#echo "$entry"
[[ -n "$entry" ]] && echo "/etc/hosts contains webhost 192.168.16.4" || echo "/etc/hosts does not contain webhost 192.168.16.4"






