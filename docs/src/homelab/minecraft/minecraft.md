# Minecraft Server on Linux VM

- [Minecraft Server on Linux VM](#minecraft-server-on-linux-vm)
  - [Modded Minecraft](#modded-minecraft)
    - [Find world version](#find-world-version)
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
