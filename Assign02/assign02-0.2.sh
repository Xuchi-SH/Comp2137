#!/bin/bash

# List of users
users=("aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

# Create users and set default shell to bash
for user in "${users[@]}"; do
	echo $user
done

# usernames=("aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
usernames=("aubrey" "captain" )

# Create users with home directory in /home and bash as default shell
for username in "${usernames[@]}"; do
    useradd -m -d "/home/$username" -s /bin/bash "$username"
	echo "Create "$username
done

# Generate SSH keys (RSA and Ed25519) for each user
for username in "${usernames[@]}"; do
    su - "$username" -c "ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''"
    su - "$username" -c "ssh-keygen -q -t ed25519 -f ~/.ssh/id_ed25519 -N ''"
	echo "ssh-keygen "$username
done

# Add public keys to authorized_keys file
for username in "${usernames[@]}"; do
    cat "/home/$username/.ssh/id_rsa.pub" >> "/home/$username/.ssh/authorized_keys"
    cat "/home/$username/.ssh/id_ed25519.pub" >> "/home/$username/.ssh/authorized_keys"
	chmod 600 /home/$username/.ssh/authorized_keys
	chown -R $username:$username /home/$username/.ssh
	echo "public key "$username
done

echo "User accounts created successfully!"
