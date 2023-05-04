# README.md

## Overview

This is the main repository for my working cookbooks, recipes, dockerfiles, configurations, and general homelab userscripts.

## Ansible Playbooks

To run playbooks, `cd` into the `/root/cookbooks/ansible` directory of the repo.

To test on a local machine, run the playbook using the command `ansible-playbook --connection=local server-playbook.yml -i 127.0.0.1`

To run the playbook on the remote machine, run using the command `ansible-playbook server-xyxplay.yml -i inventory/inventory.yml --vault-password-file location/of/your/vault-password-file.txt`

## Future Plans

- [ ] Create ansible role for templating email (postfix) on Proxmox so that I can get emails and they won't flag

## Project Structure Reference

```yaml
- bin
- group_vars
- inventory
  - group_vars
    - files with group variables set
  - host_vars
    - files host variables set
- roles
  - servers
    - netbox (example)
      - defaults
      - handlers
      - meta
      - tasks
      - templates (jinja2 configuration)
      - vars
      - vaults
      - README.md
  - services
    - ssl (example)
      - tasks
      - templates
      - vars
      - vautls
- README.md
```
