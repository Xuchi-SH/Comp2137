#!/bin/bash

set +x

sides=6
numdice=2

displayhelp ()  {
	cat <<EOF
$(basename $0) [-h] [-s N]
	-h 		display help and exit
	-s N 	specify number of sides for dice, N is a number from 2 to 20, default is 6
EOF
}

echo $#

while [ $# -gt 0 ]; do
	echo $0 ", " $1 ", " $2 ", " $3
	case "$1" in
		-h )
			echo "===h===="
			displayhelp
			exit
			;;
		-s )
			echo "===s===="
			shift
			echo $0 ", " $1 ", " $2 ", " $3
			sides=$1
			if [ -n "$side" ]; then
				if [ $sides -lt 2 -o $sides -gt 20 ]; then
					echo "wrong number"
					displayhelp
					exit 1
				fi
			else
				echo "right number $1"
				displayhelp
				exit 1
			fi
			;;
	  	* )
			echo "invalid input: '$1'"
			exit 1
			;;
	esac
	shift
done

total=0
printf "Rolling... "
for (( numrolled=0; numrolled<$numdice; numrolled++)); do
	roll=$(( RANDOM % sides + 1))
	printf "$roll "
	total=$(( roll + total ))
done
printf "\nRolled a $total\n" 


