#!/bin/bash
#Chi Xu 20061605
#06-July-2024

set -e

# Functions
log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1" >&2
}

# Network Configuration

NETPLAN_CONFIG="/etc/netplan/10-lxc.yaml"
NEW_IP="192.168.16.21/24"
MATCH_IP="192.168.16."

create_netplan_file() {
	echo "Creating new netplan configuration file..."
	cat <<EOF > $NETPLAN_CONFIG
network:
	version: 2
	ethernets:
		eth0:
			addresses: [$NEW_IP]
			routes:
			  - to: default
				via: 192.168.16.2
			nameservers:
				addresses: [192.168.16.2]
				search: [home.arpa, localdomain]
		eth1:
			addresses: [172.16.1.200/24]
EOF
	netplan apply
}

modify_netplan_file() {
	echo "Modifying existing netplan configuration file..."
#    sed -i "/addresses: \[${MATCH_IP}.*\/24\]/c\            addresses: [$NEW_IP]" $NETPLAN_CONFIG
#	sed -i "s/addresses: \[${MATCH_IP}.*\/24/addresses: [$NEW_IP]/g" $NETPLAN_CONFIG
#	sed -i "s#addresses: \[192.168.16.*\/24]/addresses: [$NEW_IP]/g" "/etc/netplan/10-lxc.yaml"
	sed -i "s#addresses: \[192.168.16.*\/24]#addresses: \[$NEW_IP]#g" "/etc/netplan/10-lxc.yaml"			
	netplan apply
}


# List of users


usernames=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
declare -A pulic_keys

pulic_keys["dennis"]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"


# Create users with home directory in /home and bash as default shell
for username in "${usernames[@]}"; do
	log "Create $username"
    useradd -m -d "/home/$username" -s /bin/bash "$username"

# Generate SSH keys (RSA and Ed25519) for each user
	log "ssh-keygen $username"
    su - "$username" -c "ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''"
    su - "$username" -c "ssh-keygen -q -t ed25519 -f ~/.ssh/id_ed25519 -N ''"

# Add public keys to authorized_keys file
	log "public key authorized_keys $username"
    cat "/home/$username/.ssh/id_rsa.pub" >> "/home/$username/.ssh/authorized_keys"
    cat "/home/$username/.ssh/id_ed25519.pub" >> "/home/$username/.ssh/authorized_keys"
	if [ "$username" == "dennis" ]; then
		echo "${ssh_keys[$username]}" >> "/home/$username/.ssh/authorized_keys"	
		usermod -aG sudo $username
	fi
	chmod 600 /home/$username/.ssh/authorized_keys
	chown -R $username:$username /home/$username/.ssh
done

log "User accounts created successfully!"
