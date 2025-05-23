# Minecraft Server on Linux VM

- [Minecraft Server on Linux VM](#minecraft-server-on-linux-vm)
  - [Modded Minecraft](#modded-minecraft)
    - [Find world version](#find-world-version)
    - [Server Install](#server-install)
  - [Spigot](#spigot)
    - [To Do](#to-do)
    - [Favorite Plugins](#favorite-plugins)
  - [Tmux](#tmux)

## Modded Minecraft

### Find world version

```shell
$ cd ~/.minecraft/saves/"New World"
$ grep DataVersion advancements/*.json
  "DataVersion": 1976
adam@adam-wee-pc:~/Downloads/The Empty-20250501T141004Z-001/the-empty$ jq .DataVersion advancements/*.json

#match with this website:
# https://minecraft.wiki/w/Data_version
```

### Server Install

Followed these docs: <https://www.linuxnorth.org/minecraft/modded_linux.html>

```shell


adam@minecraft:/opt$ mkdir /opt/minecraft
adam@minecraft:/opt$ sudo chmod 777 minecraft/

sudo apt install default-jre
update-alternatives --config java
sudo apt install screen
wget https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.0/forge-1.20.1-47.4.0-installer.jar
java -jar forge-1.20.1-47.4.0-installer.jar --installServer
rm forge-1.20.1-47.4.0-installer.jar
sudo apt install tree

# show mod folder on local PC
adam@adam-wee-pc:~/Documents/curseforge/minecraft/Instances/Solo April212025/mods$ pwd
/home/adam/Documents/curseforge/minecraft/Instances/Solo April212025/mods

# sftp mods from local gaming PC to server

```

## Spigot

```shell
root@minecraft:/opt/minecraft# sudo apt install openjdk-21-jdk
root@minecraft:/opt/minecraft# java -jar BuildTools.jar
```

### To Do

- Orefinder plugin
- restart server for no chest timer
- drop heads plugin
- classic combat plugin
- fast leaf decay
- [iron farm](https://www.youtube.com/watch?v=-oYyJ6jfSPU)

### Favorite Plugins

|   ID   |       Description       |
| :----: | :---------------------: |
| 83581  |     fast leaf decay     |
| 111907 |      ore detector       |
| 39965  |      smooth timber      |
| 74429  | fast chunk pregenerator |
| 60623  |       sleep most        |
| 101066 |       death chest       |

[Allow bedrock on Java](https://geysermc.org/)
[Vane plugin](https://oddlama.github.io/vane/)

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
