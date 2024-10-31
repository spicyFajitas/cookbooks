#!/bin/bash

cd /opt/media
#docker compose down
docker compose up -d
echo "$(date) Updated Plex container" >> /opt/media/plex-operations.log
docker image prune -af
