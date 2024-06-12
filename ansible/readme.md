# README.md

## Installation

```bash
sudo apt install ansible
```

## Ansible Playbooks

To run playbooks, `cd` into the `/cookbooks/ansible` directory of the repo.

To run a playbook against a local machine, run the command `ansible-playbook --connection=local server-playbook.yml -i 127.0.0.1`

To run the playbook on a remote machine, run using the command `ansible-playbook server-xyxplay.yml -i inventory/inventory.yml --vault-password-file vault-pass.txt`

<!-- or other location of your vault password file -->

To limit the playbook run to certain hosts, use the `--limit hostname` flag. You can limit to more than one host by specifying the group name instead of hostname or by putting multiple hosts: `--limit "host1,host2,host3,host4"`

To exclude a host from a playbook run, use the `--limit !hostname` flag.

To run a playbook in pretend mode, add the flag `--check`

## Group/Host Variable Precedence

In a basic ansible inventory file with the below syntax example, each bracket-ed line defined a group. If you want to apply specific variable overrides to a certain group, you can create `group_vars/vpn.yml` and it will override the default `group_vars/all.yml`. Since my environment does not have DNS, each host is defined as an IP address. If you wanted to override with a host_var file, you will need to name the file using the IP address that defines the host.

```ini
[all]

[separate_hosts]
192.168.10.2
192.168.10.3
[separate_hosts:vars]
ansible_user=root

[vpn]
192.168.10.4
[vpn:vars]
ansible_user=root

[linux_server]
192.168.10.5
[linux_server:vars]
ansible_user=root
```

## Common Tasks

### Updating Containers

All of the roles that are essentially just templated docker containers are able to update the docker containers with playbook runs.

## Project Structure Reference

If a more complex structure is needed, this is a good one to follow.

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

## Requirements

Ansible installed on an ansible-controller. Git installed on client.
