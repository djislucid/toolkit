#!/bin/bash

source ~/.bash_colors
	
my_crtsh="/home/dj/Toolkit/myCrt.sh"

helpText() {
	echo -e "Usage: $0 [init/help] <options>"
        echo "[options]:"
	echo -e "\twhois\t\t\t\twhois lookup"
	echo -e "\treverse\t\t\t\tReverse Whois"
	echo -e "\thelp\t\t\t\tPrint this help text"

        exit 1
}

## COMMAND LINE OPTIONS
OPTION=$1
TARGET=$2

case $OPTION in
	reverse)
		curl --silent "http://api.whoxy.com/?key=`echo $WHOXY_API`&reverse=whois&email=$TARGET" |jq -r '.search_result[]?.domain_name' |sort -u
		;;
	whois)
		curl --silent "http://api.whoxy.com/?key=`echo $WHOXY_API`&whois=$TARGET"
		;;
	help)
		helpText
		exit 0
		;;
	*)
		helpText
		exit 1
		;;
esac
