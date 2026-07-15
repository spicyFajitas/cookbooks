# homepage

k3s deployment of [gethomepage/homepage](https://gethomepage.dev), replacing
the `homepage` docker_service on `docker-host`
(`ansible/roles/docker_services/`) -- part of the broader "gradually
transition everything from Docker to k3s" goal. Migrated 2026-07.

## What's here

Kustomize-managed (`kustomization.yaml`) -- see `kubernetes/apps/_template/`
for the pattern this follows if you're scaffolding a new app:

- `00-namespace.yaml`
- `01-configmap.yaml` -- `services.yaml`, `bookmarks.yaml`, `widgets.yaml`,
  ported from `ansible/roles/docker_services/templates/homepage/*.yaml.j2`.
  Secret values that used to be Jinja2 vars (`{{ proxmox_api_key }}` etc)
  are now homepage's own `{{HOMEPAGE_VAR_x}}` substitution syntax, resolved
  from env vars at container start (works in any config file, see
  [gethomepage's docs](https://github.com/gethomepage/homepage/discussions/3403)).
  Editing this ConfigMap doesn't auto-restart the pod (no configMapGenerator
  here, to keep one pattern with the rest of `kubernetes/apps/`) --
  `kubectl -n homepage rollout restart deployment/homepage` after a change.
- `02-deployment.yaml` -- port 3000, `envFrom` the `homepage-vars` Secret
  (below), config mounted from the ConfigMap at `/app/config`. No
  `docker.sock` mount (unlike the old docker-compose version) and no
  Kubernetes-auto-discovery ServiceAccount/RBAC -- neither is used by the
  current config (it's all static entries), add them later if that changes.
  Health probes hit `/api/healthcheck` with an explicit `Host` header
  override matching the public hostname, since `HOMEPAGE_ALLOWED_HOSTS`
  would otherwise reject kubelet's pod-IP probe requests with a 403 and the
  pod would never go Ready.
- `03-service.yaml` -- ClusterIP, port 3000.
- `04-ingress.yaml` -- `homepage.spicyfajitas.com`, public via Cloudflare
  Tunnel's wildcard route, same pattern as `kubernetes/apps/magic/`. No auth
  in front of it (your call, made explicitly when migrating this) -- see the
  ingress file's own comment for the tradeoff. The admin UIs it links to
  (Proxmox, TrueNAS, Cockpit) stay LAN-only regardless, since those are
  plain LAN IPs unreachable from outside.

## Secret

Four values move from `ansible/roles/docker_services/vaults/production.yml`'s
`docker_services_secrets.homepage` into a SOPS-encrypted `SopsSecret`:
`HOMEPAGE_VAR_PROXMOX_API_TOKEN_ID`, `HOMEPAGE_VAR_PROXMOX_API_KEY`,
`HOMEPAGE_VAR_PLEX_KEY`, `HOMEPAGE_VAR_KUMA_DOMAIN` -- see
`kubernetes/platform/sops-secrets-operator/readme.md` for how the encrypt
flow works. `secrets/homepage-vars.sops.yaml` currently has
`REPLACE_WITH_REAL_VALUE` placeholders for all four. To populate real values
(get them from the ansible vault: `ansible-vault view
roles/docker_services/vaults/production.yml` from `ansible/`, or decrypt
just this once and copy):

```bash
# edit the REPLACE_WITH_REAL_VALUE placeholders to the real values, save, quit
sops kubernetes/apps/homepage/secrets/homepage-vars.sops.yaml
```

It won't decrypt cleanly on the first edit (no sops metadata yet on a
hand-written placeholder file) -- encrypt in place first if that happens:

```bash
sops --encrypt --in-place kubernetes/apps/homepage/secrets/homepage-vars.sops.yaml
# then sops <file> again for any further edits
```

## Deploy / update

```bash
export KUBECONFIG=~/.kube/k3s-homelab.yaml   # see kubernetes/readme.md
kubectl apply -k kubernetes/apps/homepage/
kubectl apply -f kubernetes/apps/homepage/secrets/homepage-vars.sops.yaml
kubectl -n homepage rollout status deployment/homepage
```

Once this is committed and pushed, Argo CD's `apps` ApplicationSet
(`kubernetes/argocd-apps/apps-appset.yaml`) picks up `kubernetes/apps/homepage/`
automatically -- the `kubectl apply -k` step above goes away, but the
`SopsSecret` still needs applying by hand (or a first Argo CD sync), same as
every other secret in this repo (kustomize deliberately never lists
`secrets/*.sops.yaml` as a resource, see `kustomization.yaml`'s comment).

## Cutover checklist

1. Apply everything above, confirm `homepage.spicyfajitas.com` loads and
   every widget (Proxmox, Plex, Uptime Kuma) renders real data, not just a
   blank/errored card.
2. Update Cloudflare DNS / anything still pointing at the old
   `10.100.10.20:3002` or `homepage.spicylab.dev` (the docker-compose
   version's `HOMEPAGE_ALLOWED_HOSTS`) to the new hostname.
3. Remove `homepage` from `ansible/roles/docker_services/tasks/main.yml`,
   delete `vars/homepage.yml` and `templates/homepage/`, and run
   `docker compose down` for it by hand on `docker-host` (matching how
   `mealie` was decommissioned -- see that role's tasks/main.yml comment).
   Leave `docker_services_secrets.homepage` in the vault untouched, same
   reasoning as the other trimmed services -- cheap to keep, no reason to
   dig through vault history if this ever needs rolling back.
