# k3s_server

## Overview

Installs the k3s control plane (single-node, schedulable by default -- see
`.claude-plan.md` at the repo root for the full cluster topology). Runs on
the VM defined by `terraform/proxmox/main.tf`'s `k3s-server` resource,
picked up by the `k3s_server` group via the dynamic Proxmox inventory.

No vault file here -- unlike most roles, this one has no static secret to
commit. The node token k3s generates at install time
(`/var/lib/rancher/k3s/server/node-token`) is read and exposed as the
`k3s_node_token` fact for the `k3s_agent` role to consume via `hostvars`
within the same playbook run. The `k3s_server` play must run before the
`k3s_agent` play in `site.yml` for this to resolve.

## Reference

See the [k3s docs](https://docs.k3s.io/) for more information regarding
setup and configuration.
