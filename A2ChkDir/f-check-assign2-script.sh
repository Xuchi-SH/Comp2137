#!/bin/bash


{
export PAGER=more
checkscript=https://zonzorp.github.io/COMP2137/check-assign2-script.sh
makecontainers=https://zonzorp.github.io/COMP2137/makecontainers.sh

echo ---Host/Student info----
echo "
Running on $(date)
Run by $USER - ($id) on host
$(hostnamectl|egrep 'hostname|Machine|Operating')
$(md5sum $0) - $(wget -q -O - $checkscript|md5sum)"
echo ------------------------
echo

echo ---Start of Assignment2.sh Check------
if [ ! -f ~/makecontainers.sh ]; then
	if wget -O ~/makecontainers.sh "$makecontainers" ; then
		echo "Retrieved makecontainers.sh script"
                chmod +x ~/makecontainers.sh
	else
		echo "Failed to retrieve makecontainers.sh script"
		exit 1
	fi
else
	if [ ! -x ~/makecontainers.sh ]; then
		chmod +x ~/makecontainers.sh || exit 1
	fi
fi

echo ---Running makecontainers.sh----------
~/makecontainers.sh --count 1 --target server --fresh || exit 1
sleep 10

# make ssh keys
ssh-keygen -f ~/.ssh/known_hosts -R server1-mgmt

echo ---Retrieving assignment2.sh script---
if wget -q -O assignment2.sh "$1"; then
	echo "Retrieved assignment2 script"
	chmod +x assignment2.sh
	if scp -o StrictHostKeyChecking=off assignment2.sh remoteadmin@server1-mgmt: ; then
		echo "Copied assignment2.sh script to server1"
	else
		echo "Failed to copy assignment2.sh to server1"
		exit 1
	fi
else
	echo "Failed to retrieve assignment2.sh script using URL '$1'"
	exit 1
fi

echo ---assignment2.sh run----
ssh -o StrictHostKeyChecking=off remoteadmin@server1-mgmt /home/remoteadmin/assignment2.sh || exit 1
echo -------------------------
echo

} >check-assign2-output.txt 2>check-assign2-errors.txt
