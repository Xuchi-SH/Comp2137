#!/bin/bash

#clean the screen and input the sudo password at the beginning.
sudo clear
lshw_net=$(sudo lshw -c network)
lshw_disk=$(sudo lshw -c disk)


#=========================System Information Section=================================
# Get the current username
USERNAME=$(whoami)
# Get the current date and time
DATE_TIME=$(date +"%Y-%m-%d/%H:%M:%S")
# Get the current hostname
HOSTNAME=$(hostname)
# Get Distribution and Version
DISTROWITHVERSION=$(< /etc/os-release grep PRETTY_NAME|sed 's/.*"\(.*\)".*/\1/')
# Get Uptime
# 1, awk: the fist column is the string of the time.
UPTIME=$(uptime -p)


# Display the system report

#=========================Hardware Information Section=================================
# Get CPU Information
# 1, grep: find the row containing the Model information; 2, sed: delete the useless characters. 
CPUMAKE=$(lscpu | grep "Vendor ID:"|sed 's/Vendor ID:\s*//')
CPUMODEL=$(lscpu | grep "Model name"|sed 's/Model name:\s*//')
# Get Maxium and Current CPU Speed. 
# 1, grep: find the rows containg speed information; 2，sort: sort the speeds; 3, head: select the first row; 4, delete useless characters.
CURSPD=$(< /proc/cpuinfo grep MHz | sort -n -k 4 | head -n 1 | sed 's/.*: //')"MHz(Current)"
MAXSPD=$(< /proc/cpuinfo grep MHz | sort -r -k 4 | head -n 1 | sed 's/.*: //')"MHz(Maximum)"
# Get Memory Size 
# 1, grep: select the row containing memory information; 2, awk: select the second column, the string of memory size.
RAMSIZE=$(sudo lshw -class memory | grep 'System Memory' -A 3 | tail -1|awk '{ print $2 }')
# Get Video Information
# 1, grep: select the row containing the VIDEO device information; 2, sed: delect uesless characters.
VIDEOINFO=$(lspci | grep -i "VGA" | sed 's/.*controller: //')

# Get the harddisk information
# 1, grep: get the section of each harddisk
# 2, 1) awk: get the disk type, manufacturer, model, logcial name and size by the key words of description, vendor, product, logical name and size
#    2) output format: title row, then disk information rows

#echo "$lshw_disk" | grep 'SCSI Disk' -A 9 | awk '
#
#BEGIN {
#    # Print the header
#    printf "%-20s %-10s %-12s %-10s\n", "   Model", " Make", " Name", " Size"
#}
#
#
#/description/ {desc = $2 " " $3}
#/vendor:/ {vendor = substr($2, 1, length($2) - 1)}
#/product:/ {for (i=2; i<=NF; i++) hdmodel=hdmodel " " $i;}
#/logical name:/ {name = $3}
#/size:/ {size = $2}
#{
#    if (desc && vendor && name && size && hdmodel) {
#        printf "%-20s %-10s %-12s %-10s\n", hdmodel, vendor, name, size
#        desc = vendor = name = size = hdmodel = ""
#    }
#}'
#
DiskInfo=$(echo "$lshw_disk" | grep 'SCSI Disk' -A 9 | awk '

BEGIN {
    # Print the header
    printf "%-20s %-10s %-12s %-10s\n", "   Model", " Make", " Name", " Size"
}


/description/ {desc = $2 " " $3}
/vendor:/ {vendor = substr($2, 1, length($2) - 1)}
/product:/ {for (i=2; i<=NF; i++) hdmodel=hdmodel " " $i;}
/logical name:/ {name = $3}
/size:/ {size = $2}
{
    if (desc && vendor && name && size && hdmodel) {
        printf "%-20s %-10s %-12s %-10s\n", hdmodel, vendor, name, size
        desc = vendor = name = size = hdmodel = ""
    }
}')


#=========================Network Information Section=================================
# Get FQND
FQNDInfo=$(hostname -f)

# Get IP Address
# There may be more than one network interfaces in the system. 
# 1, grep: find the rows containing IP adress; 2, awk: get the string after "ip="; 3, awk: get the first column, the string of the ip address 
HostIP=$(echo "$lshw_net" | grep "ip=" | awk -F'ip=' '{print $2}'|awk '{printf "%s, ", $1} END {print ""}')
# Get Gateway IP address
GateIP=$(ip route | awk '/via/ {printf "%s, ", $3}')

# Get DNS Server IP Address
# 1, awk: find the row of nameserver and get the second column, the IP address of the DNS Server.
DNSIP=$(< /etc/resolv.conf awk '/nameserver/ {print $2}')

# get the Network Interface Manufactory Names
# 1, awk: find the rows of the vendor; 2, get the string after the "vendor:" by for loop. 
NETDMAKE1=$(echo "$lshw_net" | awk '/vendor:/ {VENDER=""; for (i=2; i<=NF; i++) VENDER=VENDER$i" "; print VENDER","}')

# get the Network Interface Models
# 1, awk: find the rows of the product; 2, get the string after the "product" by for loop. 
DEVMODEL1=$(echo "$lshw_net" | awk '/product:/ {PRODUCT=""; for (i=2; i<=NF; i++) PRODUCT=PRODUCT$i" "; print PRODUCT","}')

# get the Network Interface Resource Names
# 1, awk: find the rows of the logical name; 2, get the third column, the string of the resource name. 
NETDNAME1=$(echo "$lshw_net" | awk '/logical name:/ {print $3","}')

# The ip addresses come from the command of 'ip a' and the network interface hardware informaton comes from the command of ‘lshw’
# I use array to associate the ip adress with the hardware information 
# 1, output the three strings to three new variables. I don't why I failed when I deal with the three original strings directly.
NETDNAME=$(echo $NETDNAME1)
NETDMAKE=$(echo $NETDMAKE1)
DEVMODEL=$(echo $DEVMODEL1)


# 2, cut the each string to an arry of sting by the separator characters defined by IFS
IFS=',' read -r -a netname_array <<< "$NETDNAME"
IFS=',' read -r -a netmake_array <<< "$NETDMAKE"
IFS=',' read -r -a netmodel_array <<< "$DEVMODEL"

# 3, output the information and ip adress of each network interface.
#for (( i=0; i<${#netname_array[@]}; i++ )); do
#     echo "Network Interface [$i]:"
#     echo -e "\tMake: ${netmake_array[$i]}"
#     echo -e "\tModel: ${netmodel_array[$i]}"
#     echo -e "\tName: ${netname_array[$i]}"
## 4, 1) grep: select the section by resouce name of the network interface; 2) awk: get the ipv4 and ipv4 adress 
#     IPAddr=$(ip a|grep "${netname_array[$i]}" -A 3|awk '/inet/ {printf "%s, ", $2} ')
##     echo "$IPAddr"	
#     if [ -n "$IPAddr" ]; then
#          echo -e  "\tIP Address(CIDR): ${IPAddr%??}"
#     else
#          echo -e "\tNO IP Address"
#     fi
#done
#


#=========================System Status Section=================================
# get user list
# 1, awk: combine the first columns, the user name, to a row and the user names are separated by ",".
USRLIST=$(who|awk '{printf "%s, ", $1} END {print ""}')

# get disk avaliable space information of each mount point 
# 1, awk: 1)print the title row; 2)output the 6th and 4th columns.
DiskAvai=$(df -h | grep "^/dev" | awk 'BEGIN {printf " %-20s %s\n", "Mount Point", "Available Space(Bytes)"} {printf "  %-20s %s\n", $6, $4}')


#Process Count: N
# 1, wc: count the row number.
PROCCNT=$(ps aux | wc -l)

#Load Averages: N, N, N
# 1, awk: get the string after "load average:"
LOADAVE=$(uptime|awk -F 'load average:' '{print $2}')

#Memory information
# 1, awk: find the row which is begin with "Men", and then output the second, third and fourth cloumns.
MEMAvai=$(free -h | awk '/^Mem:/ {print "Memory Allocation  Total: " $2, "Used: " $3, "Free: " $4}')

#Listening ports. The tcp and udp ports should be displayed individually.
# Get upd port list
# 1, awk: find the row of udp; 2, awk: get the port which is after ":"; 3, sort: sort the ports; 4, uniq: delete duplicate item; 5, awk: print the ports in one row.
PORTINFO=$(netstat -tuln | awk '/^udp/ {print "udp:"$4}'| awk -F ':' '{print $1" "$NF}'|sort -n  -k2| uniq | awk 'BEGIN {printf "%s", "UDP Ports: "} {printf "%s, ", $2} END {print ""}')
# delete the "," at the end of the string.

#Get tcp port list
# 1, awk: find the row of tcp; 2, awk: get the port which is after ":"; 3, sort: sort the ports; 4, uniq: delete duplicate item; 5, awk: print the ports in one row.
PORTINFO=$(netstat -tuln | awk '/^tcp/ {print "tcp:"$4}'| awk -F ':' '{print $1" "$NF}'|sort -n  -k2| uniq | awk 'BEGIN {printf "%s", "TCP Ports: "} {printf "%s, ", $2} END {print ""}')
# delete the "," at the end of the string.

#UFW Rules: DATA FROM UFW SHOW
# 1, sed: delete the second row to display more consicely; 2, sed: add a space at the beginning of each row. 
UFWStatus=$(sudo ufw status | sed 2d | sed 's/^/ /')


cat <<EOF1
System Report generated by $USERNAME, $DATE_TIME
 
System Information
------------------
Hostname: $HOSTNAME
OS: $DISTROWITHVERSION
Uptime: $UPTIME

Hardware Information
--------------------
CPU MAKE: $CPUMAKE  MODEL: $CPUMODEL
Speed: $CURSPD $MAXSPD
Ram: $RAMSIZE Bytes
Disk(s):
==========================
$DiskInfo
==========================
Video: $VIDEOINFO

Network Information
-------------------
FQDN: $FQNDInfo
Host Address: ${HostIP%??}
Gateway IP: ${GateIP%??}
DNS Server: $DNSIP
Network Interface [%d]:
    Make: %s
    Model: %s
    Name: %s
    IP Address(CIDR): %s
$(for (( i=0; i<${#netname_array[@]}; i++ )); do
     echo "Network Interface [$i]:"
     echo -e "\tMake: ${netmake_array[$i]}"
     echo -e "\tModel: ${netmodel_array[$i]}"
     echo -e "\tName: ${netname_array[$i]}"
# 4, 1) grep: select the section by resouce name of the network interface; 2) awk: get the ipv4 and ipv4 adress
     IPAddr=$(ip a|grep "${netname_array[$i]}" -A 3|awk '/inet/ {printf "%s, ", $2} ')
#     echo "$IPAddr"
     if [ -n "$IPAddr" ]; then
          echo -e  "\tIP Address(CIDR): ${IPAddr%??}"
     else
          echo -e "\tNO IP Address"
     fi
done)


System Status
------------
Users Logged In: ${USRLIST%??}
Disk Space: 
$DiskAvai
Process Count: $PROCCNT
Load Averages:$LOADAVE
$MEMAvai
Listening Network Ports: 
 ${PORTINFO%??}
 ${PORTINFO%??}
UFW Rules: 
$UFWStatus
EOF1

