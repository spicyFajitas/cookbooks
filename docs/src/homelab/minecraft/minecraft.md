# Minecraft Server on Linux VM

- [Minecraft Server on Linux VM](#minecraft-server-on-linux-vm)
  - [Modded Minecraft](#modded-minecraft)
    - [Find world version](#find-world-version)
  - [Iris Shader Modloader](#iris-shader-modloader)
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

## Iris Shader Modloader

Download Iris Installer java .jar file

<https://www.irisshaders.dev/download>

Open containing folder in Terminal

```shell
java -jar Iris-Installer-3.2.1.jar
```

Location for minecraft install is /home/adam/.minecraft

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
