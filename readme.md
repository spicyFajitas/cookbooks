# Cookbooks

## Overview

This repo contains all of my homelab cookbooks and documentation, from ansible roles and docker-compose files to (crappy) kubernetes manifests and personal userscripts.

## To Do / Project Ideas

- [ ] Separate `hosts` playbook into separate playbooks (packages, SSH, etc)
- [ ] Take separate playbooks and add as imports into other playbooks or dependencies in meta

## Support

If you are testing containers and create "development" containers with the default usernames, passwords, and configurations, you will need to completely remove the images once you are ready to create production containers with properly secure usernames, passwords, and configurations.

Run `docker-compose down -v` from the directory your `docker-compose.yml` file is located in to shut down the docker containers and destroy the container data. The volumes outside the container mapped to the host will be safe - don't worry about data loss. Then, run `docker-compose up --build` to rebuild the containers with the proper passwords and configuration.

## Current Maintainers

- [spicyFajitas](https://github.com/spicyFajitas)
