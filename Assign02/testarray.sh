usernames=("dennis" "aubrey" "yoda")
declare -A pulic_keys

pulic_keys["dennis"]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"

for username in "${usernames[@]}"; do
    echo "Create $username"
    if [ "$username" == "dennis" ]; then
        echo "key :""${pulic_keys[$username]}"
    fi
done

