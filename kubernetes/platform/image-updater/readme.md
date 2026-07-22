# image-updater (Argo CD Image Updater)

Closes a real gap flagged in `kubernetes/apps/magic/readme.md`: pushing a
new `magic` release to `ghcr.io` never auto-deployed, needed a manual
`kubectl -n magic rollout restart deployment/edhrec-analyzer` every time.
Now it's automatic -- new semver tag published, Image Updater notices
within its poll interval and bumps the running Deployment.

CRD-based config (v1.x, not the deprecated annotation-based v0.x model) --
see `01-image-updater.yaml`'s own comments for the semver/`allowTags`
reasoning and why `argocd` write-back was chosen over `git` write-back
(no auto-commits to this repo, at the cost of the deployed version not
being recorded in git history -- see that file for the full tradeoff).

## What's here

- `values.yaml` -- chart defaults already do everything needed (in-cluster
  RBAC to patch Application objects directly); explicit file for the same
  reason every platform component here uses one instead of `--set` flags.
- `01-image-updater.yaml` -- the `ImageUpdater` CR itself, targeting
  `magic`'s Application by name.

## Install

```bash
helm repo add argo https://argoproj.github.io/argo-helm --force-update
kubectl apply -f 01-image-updater.yaml
helm install argocd-image-updater argo/argocd-image-updater \
  --namespace argocd \
  --version 1.2.4 \
  -f values.yaml \
  --wait --timeout 180s
```

(`argocd` namespace already exists by the time this runs -- Argo CD's own
chart creates it -- so no separate namespace file here.)

## Verify

```bash
kubectl -n argocd logs deploy/argocd-image-updater --tail=50
```

Should show it discovering `magic`'s Application and checking
`ghcr.io/spicyfajitas/edhrec-deck-analyzer` for new tags on each poll
cycle (default interval, no override set here). After a real version bump,
confirm the live Application actually picked it up:

```bash
kubectl -n argocd get application magic -o jsonpath='{.spec.source.kustomize.images}'
```

## Extending to other apps

Add another `applicationRefs` entry to `01-image-updater.yaml` (one CR can
track multiple apps) -- `homepage` isn't wired in yet since it tracks
`:latest` only (no semver releases, see its own repo/image), which this
component deliberately doesn't try to auto-update (see `allowTags`'s
reasoning above: `latest` isn't a real version to compare against).
