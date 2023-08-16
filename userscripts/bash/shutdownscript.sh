#!/bin/bash

## Script to find all active ips in the network and shutdown all the systems by logging into it.

nmap -sP 192.168.1.0/24 | grep 192 | cut -d " " -f 5 | sed '1d' | sed '$d' > activeips.txt

while read activeips
do
  echo "$activeips"
  ssh -o "StrictHostKeyChecking no" root@$activeips 'shutdown -h now'
done < activeips.txt
