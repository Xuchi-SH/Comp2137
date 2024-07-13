#!/bin/bash

# List of users
users=("aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

# Create users and set default shell to bash
for user in "${users[@]}"; do
	echo $user
done

# usernames=("aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
usernames=("dennis" "aubrey" "captain" )
declare -A pulic_keys

pulic_keys["dennis"]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"


# Create users with home directory in /home and bash as default shell
for username in "${usernames[@]}"; do
	echo "Create "$username
    useradd -m -d "/home/$username" -s /bin/bash "$username"

# Generate SSH keys (RSA and Ed25519) for each user
	echo "ssh-keygen "$username
    su - "$username" -c "ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''"
    su - "$username" -c "ssh-keygen -q -t ed25519 -f ~/.ssh/id_ed25519 -N ''"

# Add public keys to authorized_keys file
	echo "public key authorized_keys "$username
    cat "/home/$username/.ssh/id_rsa.pub" >> "/home/$username/.ssh/authorized_keys"
    cat "/home/$username/.ssh/id_ed25519.pub" >> "/home/$username/.ssh/authorized_keys"
	if [ "$username" == "dennis" ]; then
		echo "${ssh_keys[$username]}" >> "/home/$username/.ssh/authorized_keys"	
		usermod -aG sudo $username
#		echo $username" "${pulic_keys[$username]}dd
#		echo ${pulic_keys[$username]} | sudo tee -a "/home/$username/.ssh/authorized_keys"
	fi
	chmod 600 /home/$username/.ssh/authorized_keys
	chown -R $username:$username /home/$username/.ssh
done

echo "User accounts created successfully!"
