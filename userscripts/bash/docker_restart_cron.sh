#!/bin/bash

## GCP file path -> /home/user/scripts/cloudflare_tunnel.sh

## Cloudflare Tunnel Script Checker

running=docker ps | grep cloudflare
desired='cloudflare'

if [[ "$running" != *"$desired"* ]]; then
        printf "Cloudflare tunnel does not seem to be running.\n\n"
        printf "Starting now.\n "
        #docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token <PASTE TOKEN HERE>
fi