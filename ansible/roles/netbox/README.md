# Netbox Server Role

## Table of contents

- [Overview](#overview)
- [Known Issues](#known-issues)
- [Variables](#variables)
- [Common Tasks](#common-tasks)
- [To Do](#to-do)
- [Resources](#resources)
- [Credits](#credits)
- [Current Maintainers](#current-maintainers)

## Overview

This is a role to deploy Netbox inside a docker container. The deployment is mostly automated - the super user needs to be created manually afterwards.

Easter egg: message me on Discord if you found this (I'll know you read my readme! How exciting)

### Known Issues

No current known issues. Those are yet to be discovered :upside_down_face:

## Installation

### Prep Work

As everyone's environments are different, I am not sure how you will be installing Netbox. However, you will need a Linux server - I've written this playbook using a docker container on Ubuntu, but you can use other installation methods. You will need SSH access to it - your ansible playbook will be connecting via SSH.

You will also need to look through the playbook and change any variables according to your needs (looking at the vault files and the inventory files in particular).

### Main Installation

`cd` into the `/root/cookbooks/ansible` directory of the playbook

Run `ansible-playbook server-netbox.yml -i inventory/inventory.yml --vault-password-file location/of/your/vault-password-file.txt` from your ansible controller. This will get the container mostly set up.

After the playbook runs successfully, run the command `docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser` in order to create a superuser.

## Variables

I was lazy and don't want to fill this out right now as it's 11:50 PM and I just worked 14 hours :upside_down_face:

## Common Tasks

### Upgrading Netbox

The most recent and past versions of netbox are published [to their github](https://github.com/netbox-community/netbox/releases/).

Take a database dump of the Netbox production database in case of issues with the upgrade. Change the version of Netbox in /roles/netbox/defaults/main.yml. Save the version change and test the new version in a development container.

#### Steps

1. Database dump `pg_dump netbox > netbox_dump.sql`
1. Copy database dump to new Netbox container/server
    - `sftp put/get` is good for SSH enabled connections
    - `lxc file push netbox_dump.sql netbox-dev-name/path/to/file` for pushing into container
1. Set the `secret_key` in the `configuration.py` file .
1. Restore database to new container
    - `su postgres`
    - `psql -c 'drop database netbox with (FORCE)'`
    - `psql -c 'create database netbox'`
    - `psql -c 'ALTER DATABASE netbox OWNER TO netbox'`
    - `psql netbox < netbox_dump.sql`
    - `exit`
1. The migration script may need to be ran again
    - `/opt/netbox/venv/bin/python3 /opt/netbox/netbox/manage.py migrate`
1. Restart netbox services
    - `systemctl restart netbox netbox-rq`

More information, including manual installation steps, can be found following the [Netbox documentation](https://netbox.readthedocs.io/en/stable/installation/upgrading/).

## To Do

- create a role that installs Netbox "bare metal" (essentially just not using a docker container and installing following the docs as close as possible)

## Resources

- [Official Netbox Documentation](https://docs.netbox.dev/en/stable/)
- [Netbox Docker Container Repository](https://github.com/netbox-community/netbox-docker)
- [Netbox Repository (normal install)](https://github.com/netbox-community/netbox)
- [Ansible Modules Documentation](https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html)

## Credits

Big thanks to [wastrachan](https://github.com/wastrachan/ansible-role-netbox-docker) as I copied this code as a starting point. From there I adapted it to my needs and tweaked to my liking.

## Current Maintainers

- [spicyFajitas](https://github.com/spicyFajitas)
