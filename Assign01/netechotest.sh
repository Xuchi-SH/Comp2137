sudo clear
lshw_net=$(sudo lshw -c network)

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
echo "===========================template1==========================="
cat <<NETEOF
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
NETEOF

echo "===========================template1==========================="


# 3, output the information and ip adress of each network interface.
for (( i=0; i<${#netname_array[@]}; i++ )); do
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
done
echo "============================================"
# Define the template
template=$(cat <<'EOF'
Network Interface [%d]:
    Make: %s
    Model: %s
    Name: %s
    IP Address(CIDR): %s

EOF
)

# Output the information and IP address of each network interface.
for (( i=0; i<${#netname_array[@]}; i++ )); do
    IPAddr=$(ip a | grep "${netname_array[$i]}" -A 3 | awk '/inet/ {printf "%s, ", $2}')
    if [ -n "$IPAddr" ]; then
        IPAddr=${IPAddr%??}  # Remove trailing comma and space
    else
        IPAddr="NO IP Address"
    fi
    printf "$template\n" "$i" "${netmake_array[$i]}" "${netmodel_array[$i]}" "${netname_array[$i]}" "$IPAddr"
done
