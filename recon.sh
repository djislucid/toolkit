#!/bin/bash
## Created by DJ Nelson

source ~/.bash_colors

TARGET=$1
PORTS_FILE=ports.txt
IP_FILE=ips.txt
SUBDOMAINS=subdomains.txt
HTTP_HOSTS=web-servers.txt

helpText() {
	echo "Title"
	echo -e "\nUsage: $0 [options]"
	echo "[options]:"
	echo -e "\t-t|-target\t\tSpecify the target domain"
	echo -e "\t-p|-project\t\tSpecify the name of the project directory"
	echo -e "\t-l|-list\t\tList the current projects"
	echo -e "\t-help\t\t\tPrints this help text"

	exit 0
}

function crt_sh() {
	curl -s https://crt.sh/\?q\=%25.$1\&output\=json |jq -r '.[].common_name' |sed 's/\*\.//g' | sort -u
}

# begin command-line parsing
while [ "$1" != "" ]; do
	param=`echo $1|awk -F= '{print $1}'`
	value=`echo $1|awk -F= '{print $2}'`

	# help text
	if [ $1 == "-help" ]; then
		helpText
	fi

	case $param in
		-t|-target)
			TARGET="$value"
		    	;;
		-p|-project)
			PROJECT="$value"
			;;
		-l|-list)
			LIST=true
			;;
		*)
			echo -e "[${RED}!${OFF}] $param is an incorrect option. See -help for more info."
		   	exit 1
		   	;;
	esac
	shift
done

if [ ! -z ${LIST} ]; then
	ls ~/Targets
	exit 0
fi

if [ ! -d ~/Targets/${PROJECT}/${TARGET} ]; then
	mkdir ~/Targets/$PROJECT/$TARGET && cd ~/Targets/$PROJECT/$TARGET
else
	cd ~/Targets/$PROJECT/$TARGET
fi

# initial subdomain enumeration and certificate transparency scan
amass enum -d $TARGET -ipv4 -active -o $SUBDOMAINS #-config $TOOLKIT/Configs/amass-config.ini
crt_sh $TARGET |xargs -n 1 -I{} crt_sh `echo {}` |tee -a $SUBDOMAINS

# trim IP addresses here and run masscan separately
cat $SUBDOMAINS |cut -d' ' -f2 |tr , '\n' |sort -u >$IP_FILE
sudo masscan -p $(cat ~/Toolkit/Wordlists/ports/nmap-portlist.txt) -iL $IP_FILE -oG $PORTS_FILE
sed -i '/^#/d' $PORTS_FILE

# Get live HTTP servers
cat $SUBDOMAINS |cut -d' ' -f1 |sort -u |httprobe |tee -a $HTTP_HOSTS

# do stuff depending on auth or no auth
#if [ -n "$PASS" ]; then
#	echo -e "[${BLUE}*${OFF}] Ran option $param with parameter $PASS "
#fi
