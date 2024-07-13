#!/bin/bash


{
date
echo --/etc/hosts----------
incus exec server1 sh -- -c 'cat /etc/hosts'
echo --/etc/netplan--------
incus exec server1 sh -- -c 'cat /etc/netplan/*'
echo ---applying netplan---
incus exec server1 sh -- -c 'netplan apply'
echo ---ip a---------------
incus exec server1 sh -- -c 'ip a'
echo --ip r----------------
incus exec server1 sh -- -c 'ip r'
echo ----------------------
echo


}  >>bo1-check-assign2-output.txt 2>>bo1-check-assign2-errors.txt
  

# >>check-assign2-output.txt 2>>check-assign2-errors.txt
