#!/bin/bash
#Chi Xu 16-Juyl-2024

# Ignore TERM, HUP, and INT signals
trap '' TERM HUP INT

# Default values is false
VERBOSE=false

# Functions to handle verbose output and logging
show_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo "$1"
    fi
}

show_change() {
    logger "$1"
    show_verbose "[Change]$1"
}

# Function to update the hostname
update_hostname() {
    local desired_name="$1"
    local current_name
    current_name=$(hostname)

    if [[ "$current_name" != "$desired_name" ]]; then
        echo "$desired_name" | sudo tee /etc/hostname > /dev/null
        sudo sed -i "s/$current_name$/$desired_name/g" /etc/hosts
        sudo hostnamectl set-hostname "$desired_name"
        show_change "Hostname changed from $current_name to $desired_name"
    else
        show_verbose "Hostname is already set to $desired_name"
    fi
}

# Function to update the IP address
update_ip() {
    local desired_ip="$1"
    local current_ip
    current_ip=$(hostname -I | awk '{print $1}')

    if [[ "$current_ip" != "$desired_ip" ]]; then
        sudo sed -i "s/$current_ip/$desired_ip/g" /etc/hosts
        sudo sed -i "s/$current_ip/$desired_ip/g" /etc/netplan/*.yaml
        sudo netplan apply
        show_change "IP address changed from $current_ip to $desired_ip"
    else
        show_verbose "IP address is already set to $desired_ip"
    fi
}

# Function to update the /etc/hosts file
update_hostentry() {
	echo "hostentry function $1 $2"
    local desired_name="$1"
    local desired_ip="$2"
    current_name=$(grep "$desired_ip" /etc/hosts | awk '{print $2}')
    current_ip=$(grep "$desired_name" /etc/hosts | awk '{print $1}')
    echo "current ip=$current_ip   current name=$current_name"
	echo "desire ip=$desired_ip    desire name=$desired_name"
	

	if [ -z "$(grep -E "^\s*$desired_ip\s+$desired_name(\s|$)" /etc/hosts)" ]; then
   		if [ -n "$current_name" ]; then
			echo "desire ip exists. current_name = $current_name"
            sudo sed -i "s/$current_name/$desired_name/g" /etc/hosts
            show_change "$current_name is replaced by $desired_name and $desired_ip is already in the hosts file"
   		else 
			if [ -n "$current_ip" ]; then
				echo "desire name exists. current_ip = $current_ip"
                sudo sed -i "s/$current_ip/$desired_ip/g" /etc/hosts
                show_change "$current_ip is replaced by $desired_ip and $desired_name is already in the hosts file"
			else
				echo "desire ip(desired_ip) and name(desired_name) both do not exist. $current_ip and $current_name"
	            echo "$desired_ip $desired_name" | sudo tee -a /etc/hosts > /dev/null
                show_change "$desired_ip $desired_name are added to the hosts file as a new entry"
			fi
		fi
	else
		echo "desire ip and name both exist.The entry is already in the hosts file"
	fi
}

# Parse command-line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -verbose)
            VERBOSE=true
            ;;
        -name)
            shift
            DESIRED_NAME="$1"
            ;;
        -ip)
            shift
            DESIRED_IP="$1"
            ;;
        -hostentry)
            shift
            HOST_NAME="$1"
            shift
            HOST_IP="$1"
			echo "hostentry case $HOST_NAME $HOST_IP"
            ;;
        *)
            exit 1
            ;;
    esac
    shift
done

# Apply the desired settings
[ -n "$DESIRED_NAME" ] && update_hostname "$DESIRED_NAME"
[ -n "$DESIRED_IP" ] && update_ip "$DESIRED_IP"
[ -n "$HOST_NAME" ] && [ -n "$HOST_IP" ] && update_hostentry "$HOST_NAME" "$HOST_IP"


