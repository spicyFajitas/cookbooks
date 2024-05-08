# Minecraft

## Overview

I like to run a minecraft server... big surprise...

But for real, this is the config for my minecraft server.

## Restoring from Backup

Comment out the main `mc` minecraft container and uncomment the restore container

## Updates

Every now and then minecraft will release a new update. The `itzg/minecraft-server` docker image paired with the CI I have will update the server version to the latest version automatically every night. If the dynmap plugin version is not updated for the new server version, it will fail to load. The minecraft server will still be fine.

To update the dynmap plugin:

- SSH to Docker host
- navigate to directory of plugins `/opt/minecraft/world_data/plugins`
- delete old dynmap plugin `rm Dynmap-x.y-spigot.jar`
- download new dynmap plugin
  - browse web to `https://www.spigotmc.org/resources/dynmap%C2%AE.274/`
  - click `Download now via external website`
  - right click and copy download link address
  - wget `<copied link>` into terminal
- restart minecraft server
