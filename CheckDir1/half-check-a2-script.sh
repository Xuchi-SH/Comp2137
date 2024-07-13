echo --/etc/hosts----------
incus exec server1 sh -- -c 'cat /etc/hosts'
echo --/etc/netplan--------
incus exec server1 sh -- -c 'more /etc/netplan/*'
echo ---applying netplan---
incus exec server1 sh -- -c 'netplan apply'
echo ---ip a---------------
incus exec server1 sh -- -c 'ip a'
echo --ip r----------------
incus exec server1 sh -- -c 'ip r'
echo ----------------------
echo

echo ---services status------
incus exec server1 -- sh -c 'systemctl status apache2 squid'
echo ------------------------
echo

echo ---ufw show added-------
incus exec server1 ufw show added
echo ---ufw show status------
incus exec server1 ufw status
echo ------------------------
echo

echo ---getents--------------------
incus exec server1 getent passwd {aubrey,captain,snibbles,brownie,scooter,sandy,perrier,cindy,tiger,yoda,dennis}
incus exec server1 getent group sudo
echo ---user home dir contents-----
incus exec server1 -- find /home -type f -ls
incus exec server1 -- sh -c 'more /home/*/.ssh/authorized_keys'
echo ------------------------------
echo

echo ---assignment2.sh rerun--------------------------------------------------------------------
ssh -o StrictHostKeyChecking=off remoteadmin@server1-mgmt /home/remoteadmin/assignment2.sh || exit 1
echo -------------------------------------------------------------------------------------------
echo

echo --/etc/hosts----------
incus exec server1 sh -- -c 'cat /etc/hosts'
echo --/etc/netplan--------
incus exec server1 sh -- -c 'more /etc/netplan/*'
echo ---applying netplan---
incus exec server1 sh -- -c 'netplan apply'
echo ---ip a---------------
incus exec server1 sh -- -c 'ip a'
echo --ip r----------------
incus exec server1 sh -- -c 'ip r'
echo ----------------------
echo

echo ---services status------
incus exec server1 -- sh -c 'systemctl status apache2 squid'
echo ------------------------
echo

echo ---ufw show added-------
incus exec server1 ufw show added
echo ---ufw show status------
incus exec server1 ufw status
echo ------------------------
echo

echo ---getents--------------------
incus exec server1 getent passwd {aubrey,captain,snibbles,brownie,scooter,sandy,perrier,cindy,tiger,yoda,dennis}
incus exec server1 getent group sudo
echo ---user home dir contents-----
incus exec server1 -- find /home -type f -ls
incus exec server1 -- sh -c 'more /home/*/.ssh/authorized_keys'
echo ------------------------------
echo


