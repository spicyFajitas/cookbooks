# README.md

## Installation

```bash
sudo apt install ansible
ansible-galaxy collection install -r collections/requirements.yml
```

## Cattle, not pets

Hosts here are meant to be disposable and reproducible, not hand-tuned and
irreplaceable:

1. **Packer** (`../packer/`) builds a golden VM image (Docker pre-installed).
2. **Terraform** (`../terraform/`) clones that image into a running VM
   (Proxmox) or provisions a droplet (DigitalOcean), and tags the resource
   with the exact Ansible group name it should join -- see the `tags`
   attribute on each resource in `terraform/*/main.tf`.
3. **Ansible's dynamic inventory** (`inventory/pve.proxmox.yml`,
   `inventory/digital_ocean.yml`) discovers that tagged resource
   automatically -- no manual inventory editing.
4. **`site.yml`** configures it based on which group(s) it landed in.

To replace a host: `terraform destroy` the resource, `terraform apply` a new
one, and the next `ansible-playbook site.yml` run configures it identically.
No manual SSH, no re-adding it to an inventory file by hand.

### What's still static, and why

`inventory/static.yml` carries hosts that predate this tagging scheme, plus
a couple of permanent, intentional exceptions:

- The Proxmox hypervisor itself is physical hardware, not a VM -- it will
  never show up via the Proxmox dynamic inventory plugin (that plugin
  enumerates guests, not the host it queries).
- The Ansible controller VM is a bootstrap exception: it has to exist and be
  configured before it can query dynamic inventory against itself.
- A couple of hosts (`host-04`, `host-28` in `inventory/host_vars/`) have
  undocumented purposes inherited from the old flat inventory -- find out
  what they are and either tag their Terraform resource properly or retire
  them.

Once a host's Terraform resource carries the matching tag and
`ansible-inventory --graph` confirms the dynamic plugin picks it up in the
same group, remove its entry from `static.yml` -- a host listed in both
places gets configured twice.

## Running playbooks

Everything lives in one playbook, `site.yml`. Every play is tagged with the
service/role name, so you select what to run with `--tags` instead of
picking a different file.

```bash
cd ansible

# Configure everything
ansible-playbook site.yml -i inventory --vault-password-file vault-pass.txt

# Just one service
ansible-playbook site.yml -i inventory --vault-password-file vault-pass.txt --tags plex

# One service, one host
ansible-playbook site.yml -i inventory --vault-password-file vault-pass.txt --tags docker_host --limit docker-host-01

# Dry run
ansible-playbook site.yml -i inventory --vault-password-file vault-pass.txt --check
```

To run locally: `ansible-playbook --connection=local site.yml -i 127.0.0.1`.

To exclude a host: `--limit '!hostname'`. To limit to several: `--limit "host1,host2"`.

Available tags: `common`, `helper`, `ansible`, `runner`, `docker`,
`docker_host`, `proxmox`, `plex`, `semaphore`, `twingate`, `fortune`,
`minecraft-vm`, `watchtower`, `frigate`, `grafana`, `homepage`, `mealie`,
`media`, `minecraft-docker`, `netbox`, `netdata`, `speedtest-tracker`,
`uptime-kuma`, `wyze`.

## Dynamic inventory setup

Both dynamic inventory sources fail gracefully (a warning, not a hard
error) when credentials aren't present in the environment -- `static.yml`
and `host_vars/` still load fine on their own. Set these to actually enable
discovery:

**Proxmox** (`inventory/pve.proxmox.yml`, `community.proxmox.proxmox` plugin
-- `community.general.proxmox` is deprecated and being removed from
`community.general` 15.0.0, so this repo uses the new collection):

```bash
export PROXMOX_URL=https://10.100.10.10:8006/api2/json
export PROXMOX_USER=ansible@pve
export PROXMOX_TOKEN_ID=ansible          # the token *name*, not the combined
                                          # user@realm!tokenname form
                                          # Terraform's pm_api_token_id uses
export PROXMOX_TOKEN_SECRET=...
```

**DigitalOcean** (`inventory/digital_ocean.yml`,
`community.digitalocean.digitalocean` plugin):

```bash
export DO_API_TOKEN=...
```

Verify what gets discovered before trusting it:

```bash
ansible-inventory -i inventory --graph
ansible-inventory -i inventory/pve.proxmox.yml --list
ansible-inventory -i inventory/digital_ocean.yml --list
```

`community.proxmox` may warn about ansible-core version support depending
on your installed ansible-core -- it's a warning, not fatal, but worth
checking if you bump collection versions.

## GitHub Actions CI/CD

- `ansible-lint.yml` -- static lint + `--syntax-check` on every PR touching
  `ansible/**`. Runs on GitHub-hosted runners, no infrastructure access
  needed.
- `terraform-validate.yml` -- `fmt`/`validate`/`plan` (posted as a PR
  comment) on every PR touching `terraform/**`. Read-only, never applies.
- `packer-validate.yml` -- `packer init` + `packer validate` on every PR
  touching `packer/**`. Read-only, never builds an image.
- `deploy.yml` -- on push to `main`/`master`, applies Terraform and runs
  `ansible-playbook site.yml` against real infrastructure. Gated behind the
  `production` GitHub Environment: configure a required reviewer for it in
  repo **Settings -> Environments -> production**, or this runs unattended.

The Proxmox stack, Packer validation, and the deploy job all need to reach
the private LAN (10.100.10.x), which GitHub-hosted runners can't route to.
They run on a self-hosted runner instead -- `roles/github_actions_runner`,
targeting the `runner` inventory group (`github-runner-01`,
10.100.10.21) -- labeled `[self-hosted, homelab]`.

**Repo secrets required** (Settings -> Secrets and variables -> Actions):
`PROXMOX_API_URL`, `PROXMOX_API_TOKEN_ID`, `PROXMOX_API_TOKEN_SECRET`,
`PROXMOX_USER`, `PROXMOX_TOKEN_ID`, `PKR_VAR_PROXMOX_API_URL`,
`PKR_VAR_PROXMOX_API_TOKEN_ID`, `PKR_VAR_PROXMOX_API_TOKEN_SECRET`,
`DO_API_TOKEN`, `ANSIBLE_VAULT_PASSWORD`. The runner's own GitHub PAT is
*not* one of these -- it's consumed by Ansible, not a workflow, so it lives
encrypted in `roles/github_actions_runner/vaults/production.yml` instead.

## Group/Host Variable Precedence

Group vars live in `inventory/group_vars/<group>.yml` and override
`inventory/group_vars/all.yml`. Host-specific vars (currently just
`ansible_host`) live in `inventory/host_vars/<alias>.yml`, keyed by the
alias used in `inventory/static.yml` -- not by IP.

## Common Tasks

### Updating containers

All of the roles that are essentially templated docker containers update
those containers on every `site.yml` run for their tag (`pull: always` +
`recreate: auto` on change).

## Project Structure Reference

```yaml
- ansible
  - inventory
    - static.yml          # explicit, aliased exceptions (see above)
    - pve.proxmox.yml      # dynamic: Proxmox-tagged VMs/LXCs
    - digital_ocean.yml    # dynamic: DigitalOcean-tagged droplets
    - host_vars            # ansible_host per alias
    - group_vars           # vars per group
  - roles
    - <service> (e.g. plex)
      - defaults
      - handlers
      - meta
      - tasks
      - templates (jinja2 configuration)
      - vaults
      - readme.md
  - site.yml               # single entry point, tag-driven
- README.md
```

## Requirements

Ansible installed on an ansible-controller. Git installed on client. Docker
installed on any host running container roles -- this repo installs it via
the Packer golden image (`../packer/ubuntu-server-jammy-docker.pkr.hcl`),
not via Ansible.
