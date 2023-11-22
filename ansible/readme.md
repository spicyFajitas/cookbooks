# README.md

## Installation

```bash
sudo apt install ansible
```

## Ansible Playbooks

To run playbooks, `cd` into the `/cookbooks/ansible` directory of the repo.

To run a playbook against a local machine, run the command `ansible-playbook --connection=local server-playbook.yml -i 127.0.0.1`

To run the playbook on a remote machine, run using the command `ansible-playbook server-xyxplay.yml -i inventory/inventory --vault-password-file location/of/your/vault-password-file.txt`

To limit the playbook run to certain hosts, use the `--limit hostname` flag. You can limit to more than one host by specifying the group name instead of hostname or by putting multiple hosts: `--limit "host1,host2,host3,host4"`

To run a playbook in pretend mode, add the flag `--check`

## Future Plans

- [ ] Create ansible role for templating email (postfix) on Proxmox so that I can get emails and they won't flag

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
