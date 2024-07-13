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

echo "Network configuration updated successfully."

# Update /etc/hosts
log "Updating /etc/hosts..."
sed -i '/server1/d' /etc/hosts
echo "192.168.16.21 server1" >> /etc/hosts

# Install apache2 and squid
log "Installing apache2 and squid..."
apt-get update
# Start and enable apache2 and squid
log "Starting and enabling apache2 and squid..."
systemctl enable apache2
systemctl start apache2
systemctl enable squid
systemctl start squid
apt-get -y upgrade
apt-get install -y apache2 squid


# Configure UFW firewall
log "Configuring UFW firewall..."
apt install ufw -y
systemctl enable ufw
systemctl start ufw

ufw allow in on eth0 to any port 22
ufw allow in on eth0 to any port 80
ufw allow in on eth0 to any port 8080
ufw allow in on eth0 to any port 3128
ufw allow in on eth1 to any port 80
ufw allow in on eth1 to any port 8080
ufw allow in on eth1 to any port 3128

