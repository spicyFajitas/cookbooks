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

Available tags: `common`, `helper`, `docker`, `docker_host`, `proxmox`,
`k3s-server`, `plex`, `k3s-agent`, `semaphore`, `minecraft-vm`, `grafana`,
`homepage`.

Trimmed out of `site.yml` as of 2026-07, not currently run but not
deleted -- see the note at the top of `site.yml` for how to bring one
back: `twingate`, `watchtower`, `fortune`, `ansible`
(`roles/ansible_server`), `runner` (`roles/github_actions_runner`), and
from `docker_services`: `frigate`, `media`, `netbox`, `netdata`,
`speedtest-tracker`, `uptime-kuma`, `wyze`, `minecraft-docker` (superseded
by `minecraft-vm`), and `mealie` (runs on DigitalOcean instead -- the
local containers were actually stopped, not just untagged).

`k3s-agent` depends on `k3s-server` having already run in the same
execution (it reads the control plane's join token via `hostvars`, not a
vault) -- run them together (`--tags k3s-server,k3s-agent`, or a full
untagged run), not `k3s-agent` alone.

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

No self-hosted runner as of 2026-07 (`roles/github_actions_runner` archived
-- see the note at the top of `site.yml`). GitHub-hosted runners are free
and unlimited for this public repo, but they still can't route to the
private LAN (10.100.10.x) -- that's a networking constraint, not a billing
one, so CI is scoped to what's actually cloud-reachable:

- `ansible-lint.yml` -- static lint + `--syntax-check` on every PR touching
  `ansible/**`. No infrastructure access needed.
- `terraform-validate.yml` -- `fmt`/`validate` for both stacks (local
  checks, no live API needed); `terraform plan` additionally runs for
  `digital_ocean` (public API) but *not* for `proxmox` (needs the LAN).

Not automated at all anymore -- run these manually from a machine on the
LAN, same as the k3s install above:

- `terraform plan`/`apply` for `terraform/proxmox` (needs the Proxmox API).
- `packer validate`/`build` for anything in `packer/` (the proxmox-iso
  builder validates against the Proxmox API even for `validate`, so there's
  no cloud-compatible subset like Terraform's fmt/validate).
- `ansible-playbook site.yml` itself -- nearly every active host
  (`docker-host-01`, `k3s-server-01`, `plex-01`, `semaphore-01`,
  `proxmox-hv-01`) is LAN-only, so there's no meaningful CD to automate
  from GitHub-hosted runners regardless of Terraform stack.

**Repo secrets still relevant** (Settings -> Secrets and variables ->
Actions): `DO_API_TOKEN` (terraform-validate's digital_ocean plan).
`PROXMOX_API_*`/`PKR_VAR_PROXMOX_*`/`ANSIBLE_VAULT_PASSWORD` are no longer
consumed by any workflow -- fine to leave configured or remove, your call.

## docker_services: one role for every container on the docker host

Docker-compose services on the single docker host share one role,
`roles/docker_services`, instead of each having its own near-identical
role. Currently active: `grafana`, `homepage`. See
`roles/docker_services/readme.md` for how it's structured and how to add a
service back. `--tags <service>` still selects just one.

`roles/docker_services/vaults/production.yml` holds secrets for all 11
services this role originally covered (not just the 2 active ones) --
`migrate-docker-vaults.sh` merged the old per-service vaults into it,
namespaced per service, back when the consolidation happened. The 9 no
longer active (frigate, media, mealie, minecraft-docker, netbox, netdata,
speedtest-tracker, uptime_kuma, wyze) still have their secrets sitting
there, untouched, for whenever one comes back. minecraft-docker
specifically was superseded by `minecraft-vm` (its own role/play); mealie
specifically because it runs on DigitalOcean (its local containers were
stopped and removed, not just untagged) -- neither dropped for lack of
use.

## Group/Host Variable Precedence

Group vars live in `inventory/group_vars/<group>.yml` and override
`inventory/group_vars/all.yml`. Host-specific vars (currently just
`ansible_host`) live in `inventory/host_vars/<alias>.yml`, keyed by the
alias used in `inventory/static.yml` -- not by IP.

## Common Tasks

### Updating containers

Every docker-compose service (`roles/docker_services`, plus `plex`,
`homepage` if run standalone, etc.) updates its containers on every
`site.yml` run for its tag -- `community.docker.docker_compose_v2` with
`pull: always` + `recreate: auto` is idempotent on its own, so there's no
separate "restart on change" handler to trigger.

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
    - docker_services       # one role, many docker-compose services --
      - tasks                # see roles/docker_services/readme.md
      - vars                 # per-service data instead of defaults/
      - templates/<service>
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
