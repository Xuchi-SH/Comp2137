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
REDIRECT="> /dev/null 2>&1"
#"> /dev/null 2>&1"

create_netplan_file() {
	log "Creating new netplan configuration file..."
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
	eval "netplan apply  $REDIRECT"
}

modify_netplan_file() {
	log "Modifying existing netplan configuration file..."
	sed -i "s#addresses: \[192.168.16.*\/24]#addresses: \[$NEW_IP]#g" "/etc/netplan/10-lxc.yaml"			
	eval "netplan apply  $REDIRECT"
}

if [ -f "$NETPLAN_CONFIG" ]; then
	if grep -q "addresses: \[${MATCH_IP}.*\/24\]" $NETPLAN_CONFIG; then
		modify_netplan_file
	else
		echo "No matching IP address found in the existing configuration. Creating a new configuration file..."
		create_netplan_file
	fi
else
	create_netplan_file
fi

log "Network configuration updated successfully."

# Update /etc/hosts
log "Updating /etc/hosts..."
sed -i '/server1/d' /etc/hosts
echo "192.168.16.21 server1" >> /etc/hosts

# Install apache2 and squid
log "Installing apache2 and squid..."
eval "apt-get update $REDIRECT"
eval "apt-get -y upgrade $REDIRECT"
#eval "apt-get install -y apache2 squid $REDIRECT"

# Start and enable apache2 and squid
log "Starting and enabling apache2 and squid..."
#systemctl enable apache2
#systemctl start apache2
#systemctl enable squid
#systemctl start squid


# Check if apache2 is already enabled and active
if systemctl is-enabled apache2 &>/dev/null && systemctl is-active apache2 &>/dev/null; then
  log "skip, apache2 is already enabled and running."
else
  eval "apt-get install -y apache2 $REDIRECT"
  eval "systemctl enable apache2 $REDIRECT"
  eval "systemctl start apache2 $REDIRECT"
  log "apache2 is enabled and started."
fi

# Check if squid is already enabled and active
if systemctl is-enabled squid &>/dev/null && systemctl is-active squid &>/dev/null; then
  log "skip, squid is already enabled and running."
else
  eval "apt-get install -y squid $REDIRECT"
  eval "systemctl enable squid $REDIRECT"
  eval "systemctl start squid $REDIRECT"
  log "squid is enabled and started."
fi


# Configure UFW firewall
log "Configuring UFW firewall..."
eval "apt install ufw -y $REDIRECT"
#systemctl enable ufw

eval "sudo ufw --force enable $REDIRECT"
log "ufw is enabled and started."

eval "{
ufw allow in on eth0 to any port 22
ufw allow in on eth1 to any port 22
ufw allow in on eth0 to any port 80
ufw allow in on eth0 to any port 8080
ufw allow in on eth0 to any port 3128
ufw allow in on eth1 to any port 80
ufw allow in on eth1 to any port 8080
ufw allow in on eth1 to any port 3128
}  $REDIRECT"

# List of users


usernames=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
declare -A public_keys

public_keys["dennis"]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"


# Create users with home directory in /home and bash as default shell
for username in "${usernames[@]}"; do
	if id -u "$username" >/dev/null 2>&1; then
		log "User $username already exists, skipping creation."
	else
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
			echo "${public_keys[$username]}" >> "/home/$username/.ssh/authorized_keys"	
			usermod -aG sudo $username
		fi
		chmod 600 /home/$username/.ssh/authorized_keys
		chown -R $username:$username /home/$username/.ssh
	fi
done

log "User accounts created successfully!"
