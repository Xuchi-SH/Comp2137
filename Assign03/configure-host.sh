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
    local desired_name="$1"
    local desired_ip="$2"

	if [ -z "$(grep -E "^\s*$desired_ip\s+$desired_name(\s|$)" /etc/hosts)" ]; then
		echo "$desired_ip $desired_name" | sudo tee -a /etc/hosts > /dev/null
		show_change "$desired_ip $desired_name are added to the hosts file"
	else
		show_verbose "The hosts file already contains $desired_ip $desired_name"
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


