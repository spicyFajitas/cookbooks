# k3s_agent

## Overview

Joins a host to the k3s cluster as a tainted agent. Applied to the `plex`
group (the ThinkCentre, installed **directly on the host OS**, not a VM, so
`/dev/dri` stays natively accessible for Intel QuickSync transcoding -- see
`.claude-plan.md`).

Depends on `ansible/roles/k3s_server`'s play running first in the same
`site.yml` execution: it reads the control plane's address and node token
via `hostvars[groups['k3s_server'][0]]`, so joining requires
`--tags k3s-server,k3s-agent` (or a full run), not `--tags k3s-agent` alone.

Default taint/label (`plex-only=true:NoSchedule`, `role=plex`) keep
non-Plex pods off this node; the Plex deployment needs a matching
toleration + nodeSelector.

## Reference

See the [k3s docs](https://docs.k3s.io/) for more information regarding
setup and configuration.
