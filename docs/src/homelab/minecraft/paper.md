# Linux MC Running on Paper

- [Linux MC Running on Paper](#linux-mc-running-on-paper)
  - [To Do](#to-do)
  - [Paper](#paper)
  - [Dynmap](#dynmap)
  - [Commands](#commands)
  - [Favorite Plugins](#favorite-plugins)

## To Do

## Paper

"Paper is a fork of Spigot, meaning it builds upon Spigot's code and adds its own features and optimizations. Essentially, Paper is an enhanced version of Spigot, designed for better performance and stability, especially on servers with a higher player count. Spigot, on the other hand, is the standard, more established Minecraft server software." ~ Google AI overview

<https://papermc.io/downloads/paper>

```shell
root@minecraft:/opt/minecraft/1.21.5-spigot-mason-adam/plugins/DeathChest# vim /opt/minecraft/1.21.5-spigot-mason-adam/plugins/DeathChest/config.yml
# chest:
#   expiration: -1
#   blast-protection: true
#   thief-protection:
#     enabled: true
# player-notification:
#   message: |-
#     &7You died. Your items were put into a chest. ${x} ${y} ${z}

```

## Dynmap

Make sure the tunnel is running somewhere in the network

## Commands

```terminal
/chunkgen start 1000

# /dynmap radiusrender <world> <x> <z> <block radius>
/dynmap radiusrender world 171 -353 2500
/dynmap cancelrender
/dynmap fullrender

/kill @e[type=zombie]
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
| 12038  |       vein miner        |
| 67436  |       Tree Assist       |
|  1997  |       ProtocolLib       |
| 19286  |        Backpacks        |

- [Allow bedrock on Java](https://geysermc.org/)
- [Vane](https://oddlama.github.io/vane/)
- [DynMap](https://github.com/webbukkit/dynmap)
- [BlueMap](https://github.com/BlueMap-Minecraft/BlueMap)
- [Head Drop](https://modrinth.com/plugin/headdrop?version=1.21.5&loader=paper)
- [ViaVersion](https://hangar.papermc.io/ViaVersion/ViaVersion)
- [WorldEdit](https://dev.bukkit.org/projects/worldedit/)
- 
