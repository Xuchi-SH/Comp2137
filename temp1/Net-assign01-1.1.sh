#!/bin/bash


#=========================Network Information Section=================================
# Get FQND
FQNDInfo=$(hostname -f)

# Get IP Address
# There may be more than one network interfaces in the system. 
# 1, grep: find the rows of configuration; 2, awk: get the string after "ip="; 3, awk: get the first column, the string of the ip address 
HostIP=$(sudo lshw -class network | grep configuration | awk -F'ip=' '{print $2}' | awk '{ if ($1!="") $IPAddr=$1" "} {print $IPAddr}')

# Get Gateway IP address
GateIP=$(ip route | awk '/via/ {print $3}')

# Get DNS Server IP Address
# 1, awk: find the row of nameserver and get the second column, the IP address of the DNS Server.
DNSIP=$(< /etc/resolv.conf awk '/nameserver/ {print $2}')

echo
echo "Network Information"
echo "-------------------"
echo "FQDN: $FQNDInfo"
echo "Hot Address: $HostIP"
echo "Gateway IP: $GateIP"
echo "DNS Server: $DNSIP"

# get the Network Interface Manufactory Names
# 1, awk: find the rows of the vendor; 2, get the string after the "vendor:" by for loop. 
NETDMAKE1=$(sudo lshw -class network | awk '/vendor:/ {VENDER=""; for (i=2; i<=NF; i++) VENDER=VENDER$i" "; print VENDER","}')

# get the Network Interface Models
# 1, awk: find the rows of the product; 2, get the string after the "product" by for loop. 
DEVMODEL1=$(sudo lshw -class network | awk '/product:/ {PRODUCT=""; for (i=2; i<=NF; i++) PRODUCT=PRODUCT$i" "; print PRODUCT","}')

# get the Network Interface Resource Names
# 1, awk: find the rows of the logical name; 2, get the third column, the string of the resource name. 
NETDNAME1=$(sudo lshw -class network | awk '/logical name:/ {print $3","}')

# The ip addresses come from the command of 'ip a' and the network interface hardware informaton comes from the command of ‘lshw’
# I use array to associate the ip adress with the hardware information 
# 1, output the three strings to three new variables. I don't why I failed when I deal with the three original strings directly.

#NETDNAME=$NETDNAME1
#NETDMAKE=$NETDMAKE1
#DEVMODEL=$DEVMODEL1

NETDNAME=$(echo $NETDNAME1)
NETDMAKE=$(echo $NETDMAKE1)
DEVMODEL=$(echo $DEVMODEL1)

# 2, cut the each string to an arry of sting by the separator characters defined by IFS
IFS=',' read -r -a netname_array <<< "$NETDNAME"
IFS=',' read -r -a netmake_array <<< "$NETDMAKE"
IFS=',' read -r -a netmodel_array <<< "$DEVMODEL"

# 3, output the information and ip adress of each network interface.
for (( i=0; i<${#netname_array[@]}; i++ )); do
     echo "Network Interface [$i]:"
     echo -e "\tMake: ${netmake_array[$i]}"
     echo -e "\tModel: ${netmodel_array[$i]}"
     echo -e "\tName: ${netname_array[$i]}"
# 4, 1) grep: select the section by resouce name of the network interface; 2) awk: get the ipv4 and ipv4 adress 
     IPAddr=$(ip a|grep "${netname_array[$i]}" -A 3|awk '/inet / {print $2} /inet6/ {print $2}')
     if [ -n "$IPAddr" ]; then
          echo -e  "\tIP Address(CIDR): "$IPAddr
     else
          echo -e "\tNO IP Address"
     fi
done

