#!/bin/bash
# quick tool to update the full list of bug bounty programs and get their live HTTP servers

source ~/.bash_colors

LIST=/home/dj/Hacking/BountyPrograms/all_domains.txt
PUBLIC=/home/dj/Public/Github

function help() {
        echo "Title"
        echo -e "\nUsage: $0 [options]"
        echo "[options]:"
	echo -e "\t-quiet\t\t\tDoesn't print httprobe output"
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
                -q|-quiet)
                        QUIET=true
                        ;;
                *)
                        echo -e "[${RED}!${OFF}] $param is an incorrect option. See -help for more info."
                        exit 1
                        ;;
        esac
        shift
done

eval $(ssh-agent)
ssh-add $GITHUB_KEY
if [ -d "$PUBLIC/bounty-targets-data" ]; then
	cd $PUBLIC/bounty-targets-data/data
	git pull
else
	cd $PUBLIC
	git clone https://github.com/arkadiyt/bounty-targets-data
	cd bounty-targets-data/data
fi



# do stuff depending on auth or no auth
echo -e "[${GREEN}+${OFF}] Running httprobe against domains"
echo -e "[${GREEN}+${OFF}] Writing results to $LIST"
cp $LIST $LIST.prev
if [ -z "$QUIET" ]; then
	cat domains.txt |httprobe -prefer-https |tee $LIST
else
	cat domains.txt |httprobe -prefer-https > $LIST
fi

