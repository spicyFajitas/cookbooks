# README.md

## Overview

This is the main repository for my working cookbooks, recipes, dockerfiles, configurations, and general homelab userscripts.

## Ansible Playbooks

To test on a local machine, run the playbook using the command `ansible-playbook --connection=local server-playbook.yml -i 127.0.0.1`

To run the playbook on the remote machine, run using the command `ansible-playbook server-xyxplay.yml -i inventory/inventory.yml --vault-password-file roles/servers/xyzserver/vault-pass.txt`

## Future Plans

- [ ] Create ansible role for templating email (postfix) on Proxmox so that I can get emails and they won't flag
