#!/bin/bash

if [ "$#" -eq 0 ]; then
	echo "Usage: ipblocks <ASN>"
	exit 1
fi

whois -h whois.radb.net -- '-i origin $1'|grep route:|awk '{print $2}'
