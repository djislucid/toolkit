#!/bin/bash
# this needs to be run with sudo

export GOVERSION=$(curl -s https://go.dev/dl/|grep tar.gz|grep amd64|grep linux|head -1|awk -F "/" '{print $3}'|tr -d '">,')
wget https://go.dev/dl/$GOVERSION
tar -C /usr/local -xzf $GOVERSION
rm $GOVERSION
