#!/bin/bash

dig +short $1 |xargs -n1 -I{} whois -h whois.cymru.com {}
