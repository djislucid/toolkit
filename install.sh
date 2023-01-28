#!/bin/bash
## installs custom hacking environment in Ubuntu-based systems

# !Add bettercap install!

# Check if argument was provided
if [ -z "$1" ]; then
	echo "You must specify a user! ./install.sh <username>"
	exit 1
fi

## VARIABLE DECLARATIONS
# 
USER=$1
TOOLS_DIR=/opt
TOOLKIT_DIR=~/Toolkit
EXE_DIR=/usr/local/bin
PACKAGES="
nodejs screen git build-essential make jq ruby python3 python3-pip 
nmap wget wfuzz traceroute net-tools dnsutils masscan aircrack-ng 
postgresql apache2 mariadb-server php patch ruby-dev 
zlib1g-dev liblzma-dev p0f
"

## FUNCTION DECLARATIONS
#
function basicConfig() {
	apt update -y 
	apt install $PACKAGES
	apt upgrade
	gem install optimist open-uri colorize httparty nokogiri json
	cp $TOOLKIT_DIR/Configs/.bash_aliases ~/
	cp $TOOLKIT_DIR/Configs/.bash_colors ~/
	ln -s $TOOLKIT_DIR/reconParse.rb $EXE_DIR/reconParse && chmod +x $EXE_DIR/reconParse
	mkdir /home/$USER/Targets
}

function setGoFlavor() {
	# So if ARM is specified: wget https://golang.org/dl/$GOARM
	cat /etc/issue |grep Raspbian
	if [ $? -eq 1]; then
		export GOFLAVOR="curl -s https://go.dev/dl/|grep tar.gz|grep amd64|head -1|awk -F "/dl/" '{print $2}'|awk -F "\">" '{print $1}'"
	else
		export GOFLAVOR="curl -s https://go.dev/dl/|grep tar.gz|grep armv6l|head -1|awk -F "/dl/" '{print $2}'|awk -F "\">" '{print $1}'"
	fi
}

function installGo() {
	wget https://go.dev/dl/$GOFLAVOR
	tar -C /usr/local -xzf $GOFLAVOR
	mkdir -p /home/$USER/Development/go/src/github.com && chown -R $USER.$USER ~/Development/go
	echo "export GOPATH=/home/$USER/Development/go" >> ~/.profile
	echo "export PATH=$PATH:/usr/local/go/bin:/home/$USER/Development/go/bin" >> /home/$USER/.profile
}

function configureBackup() {
	ln -s $TOOLKIT_DIR/backup.sh $EXE_DIR/backup && chmod +x $EXE_DIR/backup
	mkdir -p $TOOLKIT/Configs/backup
	printf "Do you want to initiate a new scheduled backup configuration? [y/n]: "
	read input

	if [ $input == 'y' ]; then
		printf "Backup name: "
		read input2
		backup init $input2
		echo "export CURRENT_BACKUP=$TOOLKIT_DIR/Configs/backup/$input2.json" >> /home/$USER/.profile
		source /home/$USER/.profile
	fi
}

function configureReconAPI() {
	cd $TOOLKIT_DIR/Services/recon-api && npm install
	ln -s $TOOLKIT_DIR/Services/recon-api/scripts/reconApi.rb $EXE_DIR/reconApi && chmod +x $EXE_DIR/reconApi
	cp reconapi.service /etc/systemd/system/
	systemctl enable reconapi.service
}

## BEGIN EXECUTION
# 
basicConfig()

# configure Golang
which go
if [ $? -eq 1 ]; then
	# set up golang properly	
	setGoFlavor()
	installGo()
fi

source /home/$USER/.profile

# install amass
cd $GOPATH/src/github.com
export GO111MODULE=on
go get -v github.com/OWASP/Amass/v3/...
cd $GOPATH/src/github.com/OWASP/Amass
go install ./...

# install github tools
go get -v github.com/tomnomnom/httprobe
go get -v github.com/tomnomnom/waybackurls
go get -v github.com/famasoon/crtsh
go get -u github.com/ffuf/ffuf

# install dirsearch
cd $TOOLS_DIR && git clone https://github.com/maurosoria/dirsearch.git
cd dirsearch
ln -s $TOOLS_DIR/dirsearch/dirsearch.py $EXE_DIR/dirsearch && chmod +x $EXE_DIR/dirsearch

# install massdns
cd $TOOLS_DIR && git clone https://github.com/blechschmidt/massdns
cd massdns && make
ln -s $TOOLS_DIR/massdns/bin/massdns $EXE_DIR/massdns && chmod +x $EXE_DIR/massdns

configureBackup()
configureReconAPI()

# Finishing touches
echo "Install finished. Don't forget to reboot!"

