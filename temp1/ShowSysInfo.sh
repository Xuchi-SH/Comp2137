#!/bin/bash

echo "Demo"
lscpu|grep 'Model name'
lsb_release  -a | grep -E 'Desc|Rel'
vmstat -s
