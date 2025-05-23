# Linux MC running on Spigot

- [Linux MC running on Spigot](#linux-mc-running-on-spigot)
  - [To Do](#to-do)
  - [Spigot](#spigot)
  - [Tmux](#tmux)

## To Do

## Spigot

Download [build tools](https://www.spigotmc.org/wiki/buildtools/) and then build spigot java jar

sftp plugins to server and put in /opt/minecraft/world/plugins folder

```shell
root@minecraft:/opt/minecraft# sudo apt install openjdk-21-jdk
root@minecraft:/opt/minecraft# java -jar BuildTools.jar
```

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
