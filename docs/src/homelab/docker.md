# Docker

## Overview

The docker host has cockpit installed but running on a different port. Config:

```shell
root@docker-host:~# vim /etc/systemd/system/cockpit.socket.d/listen.conf


[Socket]
ListenStream=
ListenStream=9000
```

Reference: <https://cockpit-project.org/guide/latest/listen>

## Htop but for Docker

[Glances](https://www.reddit.com/r/selfhosted/comments/filg01/ctop_cli_utility_similar_to_htop_for_docker/)

`root@docker-host:~# glances`

## Installation

### Apt-Based Distro

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Commands

- bash into the container `docker exec -it <container name> /bin/bash`

- if that does not work try `/bin/sh` instead of `/bin/bash`

- to mass-stop containers, use `for i in /opt/*; do echo "Processing $i"; cd $i && docker compose down; done`

**Prune Images**

`docker system prune -a -f`

**Remove Dangling Volumes**

`docker volume rm $(docker volume ls -qf dangling=true)`

## Bind Port Errors

```bash
Error response from daemon: driver failed programming external connectivity on endpoint semaphore-postgres-1 (fbe183265d127afc95f0cd4ccb5e7d682fed8770e44d4c9b248f14f3f2d2ef92): Bind for 0.0.0.0:5432 failed: port is already allocated
```

If you are trying to start or restart containers and you receive errors like these, make sure to stop the containers, remove the containers, remove the networks, and then try to restart the containers again.

```bash
docker compose remove semaphore
docker compose remove postgres 
docker network rm -f semaphore_default
```

## Rotate Logs

I was having this issue where my docker host started to become bloated after months of my containers running. I found out based on this [website](https://forums.docker.com/t/some-way-to-clean-up-identify-contents-of-var-lib-docker-overlay/30604/33) that it was because my logs were not being rotated.  Specifically running the commands confirm that there are some log files that are WAYYY bigger than they should be.

### Configuration

Configure log rotation at `/etc/docker/daemon.json`. The following sample has been provided, which sets json log files to have a maximum size of 10m before rotating and keeps a maximum of 3 log files.

Sample Config:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Source:

- [Log Rotation Configuration Guide](https://tech-bloggers.in/rotate-the-docker-container-log/)

## Troubleshooting

### Log Storage

Run the commands below to get the shown output. The `find` command shows the largest files, and the `du` command shows which directories/files are using the most storage. Using the results, you can use the `docker inspect` command and grep for keywords to find what containers those directories/files are associated with.

Sources:

- [RedHat KB Article](https://access.redhat.com/solutions/2334181)
- [Docker Forum](https://forums.docker.com/t/some-way-to-clean-up-identify-contents-of-var-lib-docker-overlay/30604/33)

```bash
root@docker-host:~# find /var/lib/docker/ -name "*.log" -exec ls -sh {} \; | sort -h -r | head -5
116K /var/lib/docker/containers/ff53ff8ed9987187ff062009b006719024a4c749b9ab4d18b41349fce0d181ca/ff53ff8ed9987187ff062009b006719024a4c749b9ab4d18b41349fce0d181ca-json.log
104K /var/lib/docker/containers/4e009f730bd6bd98dd5d74024ddaf0c1e2d2d65ce6194c5e8a1dd658963e77a8/4e009f730bd6bd98dd5d74024ddaf0c1e2d2d65ce6194c5e8a1dd658963e77a8-json.log
48K /var/lib/docker/containers/1dc87637ed5b31e4af4c0a7b212c7e6abc5c95f486a515464cfd475e4dcee9be/1dc87637ed5b31e4af4c0a7b212c7e6abc5c95f486a515464cfd475e4dcee9be-json.log
40K /var/lib/docker/containers/6b09985ed02a3b65bf40e018af6b52d18f4221090d0b913d5fae6a49838ec600/6b09985ed02a3b65bf40e018af6b52d18f4221090d0b913d5fae6a49838ec600-json.log
28K /var/lib/docker/containers/409aaf47c68cb6d99379f33c56d3e3921c7fe02750aea99af7764aeb4d3d78ac/409aaf47c68cb6d99379f33c56d3e3921c7fe02750aea99af7764aeb4d3d78ac-json.log
```

```bash
root@docker-host:~# du -aSh /var/lib/docker/containers/ | sort -h -r | head -n 10
104K    /var/lib/docker/containers/ff53ff8ed9987187ff062009b006719024a4c749b9ab4d18b41349fce0d181ca
76K     /var/lib/docker/containers/ff53ff8ed9987187ff062009b006719024a4c749b9ab4d18b41349fce0d181ca/ff53ff8ed9987187ff062009b006719024a4c749b9ab4d18b41349fce0d181ca-json.log
72K     /var/lib/docker/containers/6b09985ed02a3b65bf40e018af6b52d18f4221090d0b913d5fae6a49838ec600
64K     /var/lib/docker/containers/409aaf47c68cb6d99379f33c56d3e3921c7fe02750aea99af7764aeb4d3d78ac
64K     /var/lib/docker/containers/1dc87637ed5b31e4af4c0a7b212c7e6abc5c95f486a515464cfd475e4dcee9be
44K     /var/lib/docker/containers/3eb684cd93d543a44d8fd0c496d82b62d7561c572c9c6df9f99ff5dea1db4f23
40K     /var/lib/docker/containers/a0b17c5061e0c2ff9b1068dcac05f7d7b5f9bcd1e63a1338217a8799fdd565ec
40K     /var/lib/docker/containers/74a206b4f5466bdcc938842e6a804b33d526a6c5f1735d0bc8a66c36680d0353
40K     /var/lib/docker/containers/6b09985ed02a3b65bf40e018af6b52d18f4221090d0b913d5fae6a49838ec600/6b09985ed02a3b65bf40e018af6b52d18f4221090d0b913d5fae6a49838ec600-json.log
40K     /var/lib/docker/containers/4e009f730bd6bd98dd5d74024ddaf0c1e2d2d65ce6194c5e8a1dd658963e77a8
```

```bash
root@docker-host:~# docker inspect ff53ff8ed9987187ff062009b006719024a4c749b9ab4d18b41349fce0d181ca | grep -E "Name|Source"
        "Name": "/netbox-redis-1",
                "Name": "unless-stopped",
                    "Source": "netbox_netbox-redis-data",
            "Name": "overlay2"
                "Name": "netbox_netbox-redis-data",
                "Source": "/var/lib/docker/volumes/netbox_netbox-redis-data/_data",
```

### Overlay Networking

TBH Docker networking is still a mystery to me, but I do know it creates files at `/var/lib/docker/overlay2` and those can bloat up the system storage. You can fix this by running 

```bash
docker system prune -af
untagged: postgres@sha256:b08e74401dd0838898ebafac9efc3dec1090d0882277e485b7edb73730327607
deleted: sha256:5fbd2ea0d85b48a9858e9f0dbd63ef8e4db715eeefc7b6f2e051ac80f2680d4c
...
...
...
Total reclaimed space: 13.98GB
```

## Dockerfile example:

```Dockerfile
FROM alpine:3.7
RUN apk add --no-cache bash curl

WORKDIR /app

COPY minecraft-discord-webhook.sh .
COPY ./lang ./lang

CMD ["bash", "-c", "WEBHOOK_URL=$WEBHOOK_URL SERVERLOG=./logs LANGUAGE=$LANGUAGE FOOTER=$FOOTER ./minecraft-discord-webhook.sh $WEBHOOK_URL"]
```

The image builds upon the default alpine version 3.7 container. It adds two packages: bash and curl to the container image. The working directory is set as /app and then it copies a script minecraft-discord-webhook.sh into the container. It also copies a directory lang into the container. Then the container start command is defined, which is calling the script copied into the container and giving that script flags for the variables in the script.

To build this container you would run docker build . -f Dockerfile -t minecraft-discord-webhook-container. This command builds the container given the current directory “.” and using file “Dockerfile.” The output, or “target” for the built container is defined as “minecraft-discord-webhook-container”. In order to run this new container, you would run docker run minecraft-discord-webhook-container. Of course, you’ll need to set some environment variables in the docker run command, or your container will error out when trying to start.
