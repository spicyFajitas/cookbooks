# docker_services

## Overview

One role for every docker-compose service that runs on the single docker
host, replacing 11 previously separate roles (frigate, grafana, homepage,
mealie, media, minecraft-docker, netbox, netdata, speedtest-tracker,
uptime_kuma, wyze) that each duplicated the same tasks/handlers/meta
boilerplate around one templated `docker-compose.yml`.

There is exactly one task file that actually does anything --
`tasks/service.yml` -- included once per service by `tasks/main.yml`. What
differs between services is data, not code:

- `vars/<service>.yml` -- `base_dir`, any plain (non-secret) config, and a
  `docker_service_templates` list of `{src, dest}` pairs to render. Optional:
  `docker_service_extra_dirs` (subdirectories to create beyond `base_dir`),
  `docker_service_smb_mount` (frigate, media, minecraft-docker mount an SMB
  share before templating), `docker_service_user` (media runs as a dedicated
  uid/gid), `docker_service_remove_files` (netbox cleans up files from an
  older layout).
- `templates/<service>/` -- the actual `docker-compose.yml.j2` and friends,
  relocated essentially unchanged from the old per-service roles.
- `vaults/production.yml` -- one encrypted file, secrets namespaced per
  service (`docker_services_secrets.<service>.<key>`) so that two services
  reusing a generic-sounding variable name (`base_domain`, `discord_webhook`,
  `cf_tunnel_api` are each used by *multiple* services here, for *different*
  values) can never collide. `service.yml` loads only the current service's
  slice via `include_vars: {name: docker_service_secrets}` and re-flattens it
  with `set_fact` so every template's variable references
  (`{{ base_domain }}`, `{{ discord_webhook }}`, ...) are completely
  unchanged from before the consolidation.

There is no handler / `notify` indirection. `community.docker.docker_compose_v2`
with `pull: always` + `recreate: auto` is already idempotent on its own --
running it every play only changes anything when the image or the rendered
compose file actually changed, so there's nothing a separate "restart on
change" handler adds.

## Adding a new service

1. `vars/<service>.yml` -- `base_dir` + `docker_service_templates` (+ any
   optional keys above).
2. `templates/<service>/*.j2`.
3. If it has secrets: add a `<service>:` block under `docker_services_secrets`
   in `vaults/production.yml` (`ansible-vault edit`).
4. Add one `include_tasks` block to `tasks/main.yml`, tagged with the
   service's name -- **must** use `apply: tags: [...]`, not a bare `tags:`
   on the include itself. A bare `tags:` on a dynamic `include_tasks` only
   tags the include action, not the tasks inside the included file --
   `--tags <service>` then matches the include (prints `included: ...`,
   looks like it worked) but silently skips every task inside `service.yml`
   with no error and no "skipping:" message. This isn't hypothetical: it's
   exactly what happened here from when this role was created until
   2026-07, when a real config change (a new Prometheus scrape target)
   reported `changed=0` and forced a debugging session to find it. Verify a
   new service's include actually executes with `ansible-playbook site.yml
   --tags <service>` and check for real `changed:`/task output, not just a
   green "included:" line.

## Known pre-existing quirks carried forward as-is

- `media`'s old `templates/smb.j2` was never referenced by any task -- not
  carried forward.
- `uptime_kuma` previously had two compose template variants gated on
  `when: inventory_hostname == "10.100.10.20"`, a hardcoded IP left over
  from before the inventory was switched to named aliases -- that condition
  silently never matched after the rename, so this service's config file
  stopped updating without erroring. Fixed by dropping the condition (the
  play's `hosts: docker_host` targeting already scopes this correctly) and
  keeping only the template variant that was actually in use
  (`local-docker-compose.yml.j2`, now just `docker-compose.yml.j2` here).
- `grafana`'s `docker-compose.yml.j2` had two bugs that had presumably
  never actually run correctly in production, only found once the
  `include_tasks`/`apply` bug above was fixed and this role's grafana tag
  finally executed for real: a literal tab character mixed into YAML
  indentation (line 7, invalid YAML, broke `docker compose ps`/`up`
  entirely), and `--storage.tsdb.retention.time=30d` attached to the
  `node_exporter` command (a Prometheus flag, not a node_exporter one --
  node_exporter doesn't have a TSDB -- crash-looped with `unknown long
  flag`). Fixed: tab replaced with spaces, the retention flag moved to the
  `prometheus` service where it was presumably meant to go.
- **Known sharp edge, not fully fixed**: the secrets-flattening step
  (`set_fact: args: "{{ docker_service_secrets }}"` in `service.yml`) has
  the same cross-service leakage shape as the `docker_service_extra_dirs`
  bug above -- it *adds* each service's secret keys as flat facts but
  never removes the previous service's. Currently moot with only `grafana`
  active in `tasks/main.yml` (homepage removed 2026-07, migrated to k3s) --
  re-check for key-name overlap the moment a second service gets added
  back. Adding a service whose secrets *do* share a name with an
  earlier-running one in `tasks/main.yml` will silently leak the earlier
  value, the same way `docker_service_extra_dirs` did. Not fixed here
  because doing so properly means templates reference
  `docker_service_secrets.<key>` instead of bare `{{ key }}`, which touches
  every template -- reasonable to defer until it actually bites, but worth
  knowing before assuming secrets isolation is airtight.
