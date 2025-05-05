# Minecraft Server on Linux VM

- [Minecraft Server on Linux VM](#minecraft-server-on-linux-vm)
  - [Find world version](#find-world-version)
  - [Server Install](#server-install)
  - [Tmux](#tmux)

## Find world version

```shell
$ cd ~/.minecraft/saves/"New World"
$ grep DataVersion advancements/*.json
  "DataVersion": 1976
adam@adam-wee-pc:~/Downloads/The Empty-20250501T141004Z-001/the-empty$ jq .DataVersion advancements/*.json

#match with this website:
# https://minecraft.wiki/w/Data_version
```

## Server Install

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

## Tmux

```txt
# detach
CTRL+B > D

# re-attach
tmux ls
tmux attach -t 0
```

root@minecraft:/opt/minecraft# sudo apt remove openjdk-21-jre-headless:amd64
