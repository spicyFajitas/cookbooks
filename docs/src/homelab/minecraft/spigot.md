# Linux MC with Spigot Plugins

- [Linux MC with Spigot Plugins](#linux-mc-with-spigot-plugins)
  - [To Do](#to-do)
  - [Spigot](#spigot)
  - [Dynmap](#dynmap)
  - [Favorite Plugins](#favorite-plugins)
  - [Tmux](#tmux)

## To Do

- Orefinder plugin
- restart server for no chest timer
- drop heads plugin
- classic combat plugin
- fast leaf decay
- [iron farm](https://www.youtube.com/watch?v=-oYyJ6jfSPU)

## Spigot

Download [build tools](https://www.spigotmc.org/wiki/buildtools/) and then build spigot java jar

sftp plugins to server and put in /opt/minecraft/world/plugins folder

```shell
root@minecraft:/opt/minecraft# sudo apt install openjdk-21-jdk
root@minecraft:/opt/minecraft# java -jar BuildTools.jar
root@minecraft:/opt/minecraft/1.21.5-spigot-mason-adam/plugins/DeathChest# vim /opt/minecraft/1.21.5-spigot-mason-adam/plugins/DeathChest/config.yml
# chest:
#   expiration: -1
#   thief-protection:
#     enabled: true
```

## Dynmap

Make sure the tunnel is running somewhere in the network

```terminal
/chunkgen start 1000
# /dynmap radiusrender <world> <x> <z> <block radius>
/dynmap radiusrender world 171 -353 2500
/dynmap cancelrender
/dynmap fullrender
```

## Favorite Plugins

Search for plugin info and download by searching "spigot [plugin ID from table]"

|   ID   |       Description       |
| :----: | :---------------------: |
| 83581  |     fast leaf decay     |
| 111907 |      ore detector       |
| 39965  |      smooth timber      |
| 74429  | fast chunk pregenerator |
| 60623  |       sleep most        |
| 101066 |       death chest       |
| 19510  |     classic combat      |

- [Allow bedrock on Java](https://geysermc.org/)
- [Vane plugin](https://oddlama.github.io/vane/)
- [DynMap](https://github.com/webbukkit/dynmap)
- [BlueMap](https://github.com/BlueMap-Minecraft/BlueMap)

## Tmux

```txt
# detach
CTRL+B > D

# re-attach
tmux ls
tmux attach -t 0

# scroll
Ctrl + b, then [
```

root@minecraft:/opt/minecraft# sudo apt remove openjdk-21-jre-headless:amd64
