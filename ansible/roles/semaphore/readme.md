# Semaphore

## Overview

This playbook mostly completely sets up an Ansible Semaphore server. Some follow up configuration tasks are included as I didn't want to create ansible tasks to enter into the docker container and execute commands as I foresaw a potential issue of the container name changing in the future.

## After Installation

- `cd` into the {{ base_dir }} of the container (/opt/semaphore)
- bash into the container `docker exec -it <container name> /bin/bash`
    - if that does not work try `/bin/sh` instead of `/bin/bash`
- create an SSH private key file at `/home/semaphore/.ssh/id_ed25519`
- copy the private key in the lxd container at `/root/.ssh/id_ed25519` and paste into docker container location from previous step
- change the permissions on the private SSH file to `0600`
