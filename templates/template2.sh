#!/bin/bash

source ~/.bash_colors

function help() {
	echo "Title"
	echo -e "\nUsage: $0 [options]"
	echo "[options]:"
	echo -e "\t-help\t\t\tPrints this help text"

	exit 0
}

# begin command-line parsing
while [ "$1" != "" ]; do
	param=`echo $1|awk -F= '{print $1}'`
	value=`echo $1|awk -F= '{print $2}'`

	# help text
	if [ $1 == "-help" ]; then
		help
	fi

	case $param in
		-p|-psk)
			PASS="$value"
		    	;;
		*)
			echo -e "[${RED}!${OFF}] $param is an incorrect option. See -help for more info."
		   	exit 1
		   	;;
	esac
	shift
done

# do stuff depending on auth or no auth
if [ -n "$PASS" ]; then
	echo -e "[${BLUE}*${OFF}] Ran option $param with parameter $PASS "
fi
