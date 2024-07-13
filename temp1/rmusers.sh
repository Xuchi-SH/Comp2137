#!/bin/bash

# List of usernames to delete
usernames=(
    dennis
    aubrey
    captain
    snibbles
    brownie
    scooter
    sandy
    perrier
    cindy
    tiger
    yoda
)

# Iterate over each username and delete the user along with their home directory
for username in "${usernames[@]}"; do
    # Check if the user exists before attempting to delete
    if id "$username" &>/dev/null; then
        echo "Deleting user: $username and their home directory..."
        sudo userdel -r "$username"
        if [ $? -eq 0 ]; then
            echo "Successfully deleted user: $username"
        else
            echo "Failed to delete user: $username"
        fi
    else
        echo "User $username does not exist, skipping..."
    fi
done

echo "User deletion process completed."

