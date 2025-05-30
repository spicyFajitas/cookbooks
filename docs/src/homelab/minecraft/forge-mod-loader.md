# Linux MC with Forge Mods

- [Linux MC with Forge Mods](#linux-mc-with-forge-mods)
  - [Modded Minecraft](#modded-minecraft)
    - [Server Install](#server-install)

## Modded Minecraft

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

root@minecraft:/opt/minecraft# sudo apt remove openjdk-21-jre-headless:amd64
