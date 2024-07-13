#!/bin/bash

usernames=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
declare -A public_keys

public_keys["dennis"]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"

# Create users with home directory in /home and bash as default shell
for username in "${usernames[@]}"; do
    if id -u "$username" >/dev/null 2>&1; then
        echo "User $username already exists, skipping creation."
    else
        echo "Creating user $username"
        useradd -m -d "/home/$username" -s /bin/bash "$username"

        echo "Generating SSH keys for $username"
        su - "$username" -c "ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''"
        su - "$username" -c "ssh-keygen -q -t ed25519 -f ~/.ssh/id_ed25519 -N ''"
    fi

    echo "Adding public keys to authorized_keys for $username"
    cat "/home/$username/.ssh/id_rsa.pub" >> "/home/$username/.ssh/authorized_keys"
    cat "/home/$username/.ssh/id_ed25519.pub" >> "/home/$username/.ssh/authorized_keys"

    if [ "$username" == "dennis" ]; then
        echo "${public_keys[$username]}" >> "/home/$username/.ssh/authorized_keys"
        usermod -aG sudo "$username"
    fi

    chmod 600 /home/$username/.ssh/authorized_keys
    chown -R "$username:$username" /home/$username/.ssh

    echo "Configuration for $username completed"
done

echo "All user accounts created and configured successfully."

