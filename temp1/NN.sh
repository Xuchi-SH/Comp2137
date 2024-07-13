#!/bin/bash

# 1, awk: find the rows of the vendor; 2, get the string after the "vendor:" by for loop. 
NETDMAKE1=$(sudo lshw -class network | awk '/vendor:/ {VENDER=""; for (i=2; i<=NF; i++) VENDER=VENDER$i" "; print VENDER","}')

# The ip addresses come from the command of 'ip a' and the network interface hardware informaton comes from the command of ‘lshw’
# I use array to associate the ip adress with the hardware information 
# 1, output the three strings to three new variables. I don't why I failed when I deal with the three original strings directly.

#NETDMAKE=$NETDMAKE1

NETDMAKE=$(echo $NETDMAKE1)
#NETDMAKE=$(echo "$NETDMAKE1")

echo "${#netmake_array[@]}"

# 2, cut the each string to an arry of sting by the separator characters defined by IFS
IFS=", " read -r -a netmake_array <<< "$NETDMAKE"

# 3, output the information and ip adress of each network interface.
for (( i=0; i<${#netmake_array[@]}; i++ )); do
     echo -e "Make: ${netmake_array[$i]}"
done

