#!/bin/bash

#=========================System Status Section=================================
echo
echo "System Status"
echo "------------"
# get user list
# 1, awk: combine the first columns, the user name, to a row and the user names are separated by ",".
USRLIST=$(who|awk '{printf "%s, ", $1} END {print ""}')
# 2, output the user list to a new variable. I don't why I failed when I deal with the string directly.
USRLIST1=$(echo $USRLIST)
# 3, delete the last "," which is at the end of the user list
USRLIST1=${USRLIST1%?}
echo "Users Logged In: $USRLIST1"

# get disk avaliable space information of each mount point 
echo "Disk Space: "
# 1, awk: 1)print the title row; 2)output the 6th and 4th columns.
df -h | awk 'BEGIN {printf "%-20s %s\n", "Mount Point", "Available Space(Bytes)"} NR>1 {printf "%-20s %s\n", $6, $4}'


#Process Count: N
# 1, wc: count the row number.
PROCCNT=$(ps aux | wc -l)
echo "Process Count: $PROCCNT"

#Load Averages: N, N, N
# 1, awk: get the string after "load average:"
LOADAVE=$(uptime|awk -F 'load average:' '{print $2}')
echo "Load Averages: $LOADAVE"

#Memory information
# 1, awk: find the row which is begin with "Men", and then output the second, third and fourth cloumns.
free -h | awk '/^Mem:/ {print "Memory Total: " $2, "Used: " $3, "Free: " $4}'

#Listening ports. The tcp and udp ports should be displayed individually.
echo "Listening Network Ports: "
# Get upd port list
# 1, awk: find the row of udp; 2, awk: get the port which is after ":"; 3, sort: sort the ports; 4, uniq: delete duplicate item; 5, awk: print the ports in one row.
PORTINFO=$(netstat -tuln | awk '/^udp/ {print "udp:"$4}'| awk -F ':' '{print $1" "$NF}'|sort -n  -k2| uniq | awk 'BEGIN {printf "%s", "UDP Ports: "} {printf "%s, ", $2} END {print ""}')
# 2, output the port list to a new variable. I don't why I failed when I deal with the string directly.
PORTINFO1=$(echo "$PORTINFO")
# 3, delete the last "," which is at the end of the user list
PORTINFO1=${PORTINFO1%?}
echo "$PORTINFO1"

#Get tcp port list
# 1, awk: find the row of tcp; 2, awk: get the port which is after ":"; 3, sort: sort the ports; 4, uniq: delete duplicate item; 5, awk: print the ports in one row.
PORTINFO=$(netstat -tuln | awk '/^tcp/ {print "tcp:"$4}'| awk -F ':' '{print $1" "$NF}'|sort -n  -k2| uniq | awk 'BEGIN {printf "%s", "TCP Ports: "} {printf "%s, ", $2} END {print ""}')
# 2, output the port list to a new variable. I don't why I failed when I deal with the string directly.
PORTINFO1=$(echo "$PORTINFO")
# 3, delete the last "," which is at the end of the user list
PORTINFO1=${PORTINFO1%?}
echo "$PORTINFO1"

#UFW Rules: DATA FROM UFW SHOW
echo "UFW Rules: "
# 1, sed: delete the second row to display more consicely.
sudo ufw status | sed 2d
