#!/bin/bash

PUBLIC=/home/dj/Public/Github
cd $PUBLIC/bounty-targets-data
NEW=$(git --no-pager diff @^ data/wildcards.txt |grep ^+ |grep -v data/wildcards.txt)

eval $(ssh-agent) &>/dev/null
ssh-add $GITHUB_KEY
git pull &>/dev/null

for wildcard in $NEW; do
	# each one of these needs to get amass'd, and httprobe'd, potentially httpx'd
	# and then stored in mongodb with your custom tool that you haven't made yet
	# even better, this could pipe to your mongodb tool which stores them in a JSON object with the date or something
	# then alerts to new storage
	echo $wildcard |cut -c 4-
done

