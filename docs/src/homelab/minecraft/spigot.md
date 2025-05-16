# Linx MC with Spigot Plugins

- [Linx MC with Spigot Plugins](#linx-mc-with-spigot-plugins)
  - [Spigot](#spigot)
    - [To Do](#to-do)
    - [Favorite Plugins](#favorite-plugins)
  - [Tmux](#tmux)

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
