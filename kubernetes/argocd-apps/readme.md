# argocd-apps

App-of-apps root. `root.yaml` is the only manifest in this whole
`kubernetes/` tree that needs a manual `kubectl apply` ever again --
everything else, including the rest of this directory, becomes
self-managing once it's applied.

## Bootstrap (one-time)

```bash
export KUBECONFIG=~/.kube/k3s-homelab.yaml
kubectl apply -f kubernetes/argocd-apps/root.yaml
```

From that point on:

- `root.yaml` watches this directory (`kubernetes/argocd-apps/`) -- any
  other `Application`/`ApplicationSet` manifest added here becomes
  self-managing automatically. Adding a new platform component means
  adding its `platform-<name>.yaml` here, same "add a file, open a PR"
  workflow apps get via `apps-appset.yaml`.
- `apps-appset.yaml` watches `kubernetes/apps/*` -- any new app directory
  (see `kubernetes/apps/_template/`) becomes an Application automatically.
- `platform-*.yaml` -- one pair of Applications per platform component
  (Helm chart + values from git as one Application, any plain manifests
  alongside it as a second) for cert-manager, external-dns, cloudflared,
  and Argo CD itself.

## Sync policy: automated, no prune, no self-heal (except Argo CD itself)

`automated: {}` with neither `prune` nor `selfHeal` set is deliberately
the least aggressive form of auto-sync:

- **Automated** (not manual): merges to `main` roll out on their own,
  per the actual ask that started this -- no one has to remember to run
  `kubectl apply` or click "sync" in the UI.
- **No prune**: deleting a resource from git does *not* delete it from the
  cluster automatically. Removing something cleanly needs an explicit
  `kubectl delete`, not just "it's not in git anymore." Safer default while
  this is still new -- revisit once trust in the pipeline is established.
- **No self-heal**: manual `kubectl` changes (debugging, live
  troubleshooting -- see `kubernetes/apps/magic/readme.md`'s DNS/tunnel
  debugging story, entirely done via direct `kubectl`/`helm` commands)
  don't get silently reverted by Argo CD mid-investigation. Argo CD will
  just show the Application as "OutOfSync" until the next git-driven sync
  reconciles it, rather than fighting you in real time.

`argocd`'s own Application (`platform-argocd.yaml`) is the one exception --
`selfHeal: true` there, since Argo CD losing track of its own
configuration is a worse failure mode than it losing track of an app.

Tighten this later (`prune: true`, `selfHeal: true`) once you trust the
pipeline enough that "matches git exactly, always" is worth more than
"never surprises me mid-debug."

## No credentials needed for any of this

`spicyFajitas/cookbooks` is a public repo -- every source above is a plain
HTTPS URL (this repo, or a public Helm chart repo), no deploy key, no
GitHub token, nothing. The only secrets anywhere in this cluster are the
Cloudflare API tokens (`kubernetes/platform/cert-manager/readme.md`,
`kubernetes/platform/external-dns/readme.md`) and the tunnel token
(`kubernetes/platform/cloudflared/readme.md`), none of which Argo CD
itself needs to know about.

## Argo CD UI

<https://argocd.spicyfajitas.com> (LAN-only, not on the public wildcard
route -- see `kubernetes/platform/argocd/01-ingress.yaml`). Login `admin` /
initial password from:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Change it and delete that secret afterward (Argo CD's own recommendation).
