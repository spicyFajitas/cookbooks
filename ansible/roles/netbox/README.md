# Netbox Server Role

## Table of contents

- [Overview](#overview)
- [Known Issues](#known-issues)
- [Software](#software)
- [Requirements](#requirements)
- [Installation](#installation)
- [Variables](#variables)
- [Common Tasks](#common-tasks)
- [Usage](#usage)
- [To Do](#to-do)
- [Resources](#resources)
- [Disaster Recovery](#disaster-recovery)
- [Credits](#credits)
- [Current Maintainers](#current-maintainers)

## Overview

This is a role to deploy Netbox inside a docker container. The deployment is mostly automated - the super user needs to be created manually afterwards.

Easter egg: message me on Discord if you found this (I'll know you read my readme! How exciting)

### Known Issues

No current known issues. Those are yet to be discovered :upside_down_face:

## Software

## Requirements

Ansible installed on an ansible-controller. Git installed on client.

## Installation

### Prep Work

As everyone's environments are different, I am not sure how you will be installing Netbox. However, you will need a Linux server - I've written this playbook using an Ubuntu LXD container, but you can use other flavors. You will need SSH access to it - your ansible playbook will be connecting via SSH.

You will also need to look through the playbook and change any variables according to your needs (looking at the vault files and the inventory files in particular).

### Main Installation

Run `ansible-playbook server-netbox.yml -i inventory/inventory.yml --vault-password-file location/of/your/vault-password-file.txt` from your ansible controller. This will get the container mostly set up.

After the playbook runs successfully, run the command `docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser` in order to create a superuser.

## Variables

I was lazy and don't want to fill this out right now as it's 11:50 PM and I just worked 14 hours :upside_down_face:

## Common Tasks

## Usage

TBH I think this section is redundant and I think it will need to be removed from my `readme.md` template.

## To Do

- Flesh out this `readme.md` file
- Ensure that upgrades are automatically taken care of with the playbook. Right now, the playbook is "*production ready*" up to installing Netbox from scratch. I have not worked on upgrades yet, which is why I opted to install v3.4.8 instead of the latest version at the time of writing this (v3.5.0)
- create a role that installs Netbox "bare metal" (essentially just not using a docker container and installing following the docs as close as possible)

## Resources

- [Official Netbox Documentation](https://docs.netbox.dev/en/stable/)
- [Netbox Docker Container Repository](https://github.com/netbox-community/netbox-docker)
- [Netbox Repository (normal install)](https://github.com/netbox-community/netbox)
- [Ansible Modules Documentation](https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html)

## Disaster Recovery

## Credits

Big thanks to [wastrachan](https://github.com/wastrachan/ansible-role-netbox-docker) as I copied this code as a starting point. From there I adapted it to my needs and tweaked to my liking.

## Current Maintainers

- [spicyFajitas](https://github.com/spicyFajitas)
