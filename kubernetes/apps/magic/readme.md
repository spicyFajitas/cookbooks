# magic (EDHRec Deck Analyzer)

k3s deployment of `spicyFajitas/magic`. **Live in production** at
<https://magic.spicyfajitas.com> as of 2026-07 -- hard-cutover from the
DigitalOcean droplet that used to serve it (the DO tunnel connector was
turned off before cutover, not after, since Cloudflare Tunnels
load-balance across every connector on one tunnel). Source repo:
`/Users/adam/Documents/code/magic` locally,
`ghcr.io/spicyfajitas/edhrec-deck-analyzer` for the built image.

## What's here

Kustomize-managed (`kustomization.yaml`) -- see `kubernetes/apps/_template/`
for the pattern this follows if you're scaffolding a new app:

- `00-namespace.yaml`
- `01-pvc.yaml` -- `cache/` and `output/` from the app, on k3s's built-in
  `local-path` StorageClass. Fine for a single-node cluster; move to NFS
  (TrueNAS, per `.claude-plan.md`'s storage plan) if this ever needs to
  survive a node rebuild or scale beyond one replica. Losing this data
  isn't a real incident either way -- it's just re-fetched from
  EDHRec/Scryfall.
- `02-deployment.yaml` -- 1 replica (RWO PVCs + a UI don't benefit from HA
  here), health probes on Streamlit's built-in `/_stcore/health`.
- `03-service.yaml` -- two Services: `edhrec-analyzer` (ClusterIP, what the
  Ingress routes to) and `edhrec-analyzer-metrics` (NodePort `:30852` --
  the external homelab Prometheus scrapes the node IP:port directly, see
  `ansible/roles/docker_services/templates/grafana/prometheus.yml.j2`).
- `04-ingress.yaml` -- `magic.spicyfajitas.com` (production) and
  `magic-k3s.spicyfajitas.com` (kept as a secondary host for direct-to-cluster
  testing that doesn't depend on Cloudflare's edge). No
  `external-dns-managed` annotation -- DNS for both is handled by
  Cloudflare Tunnel's wildcard route (`*.spicyfajitas.com` -> Traefik, see
  `kubernetes/platform/cloudflared/readme.md`), not external-dns.

## Deploy / update

```bash
export KUBECONFIG=~/.kube/k3s-homelab.yaml   # see kubernetes/readme.md
kubectl apply -k kubernetes/apps/magic/
kubectl -n magic rollout status deployment/edhrec-analyzer
```

Once Argo CD is live (`kubernetes/platform/argocd/`), this becomes
"merge to main" -- see that directory's readme.

New image pushed to `ghcr.io`? Nothing auto-deploys it yet (no
image-updater controller) -- pick it up with:

```bash
kubectl -n magic rollout restart deployment/edhrec-analyzer
```

## Known issue: metrics don't start until someone loads the page

App-code issue in the `magic` repo, not this one: `web_app.py` starts the
Prometheus metrics server (`start_http_server(8502)`) inside an
`@st.cache_resource`-decorated function called at module level. That only
actually *executes* the first time Streamlit runs the script for a real
session -- which needs a real WebSocket client (an actual browser), not
just an HTTP GET. `/_stcore/health` is up right away (so liveness/readiness
probes are unaffected), but the Prometheus scrape target
(`magic-edhrec-analyzer`) shows down until someone visits the site at least
once after each pod restart. Fix belongs in the `magic` repo: move
`start_http_server` out of the `st.cache_resource`-gated function so it
runs unconditionally at import time.

## Monitoring

- Prometheus scrape target: see the note in `prometheus.yml.j2` above.
  Applied automatically next time the `grafana` docker_service tag runs
  (`ansible-playbook site.yml --tags grafana`).
- Grafana dashboard: `ansible/roles/docker_services/files/edhrec-grafana-dashboard.json`,
  copied from the magic repo. Import manually (Grafana -> Dashboards ->
  Import) -- see that file's neighboring `files/README.md`.

## The DNS/tunnel debugging story, briefly

Getting from "deployed" to "actually reachable" took a while and involved
two real, distinct bugs, not Cloudflare being unreliable (the initial,
wrong diagnosis):

1. **external-dns fighting the tunnel for the same hostname.** Setting
   `cloudflare-proxied: "false"` created a direct un-proxied A record to
   Traefik's private LAN IP, which Cloudflare flags ("reserved IP") and
   won't serve properly for public resolution -- wrong pattern for a
   tunnel-exposed hostname. Trying to exclude the Ingress via
   `external-dns.alpha.kubernetes.io/exclude: "true"` didn't work (not a
   real annotation in this chart/version) -- external-dns kept silently
   recreating the record every ~1 minute, including seconds after manual
   deletion, which looked exactly like DNS propagation failure. Fixed by
   switching external-dns to opt-in via `annotationFilter` (see
   `kubernetes/platform/external-dns/readme.md`) instead of trying to
   exclude specific resources.
2. **The tunnel's Public Hostname route pointed at a stale raw IP**
   (`http://10.108.0.2:8501`, not part of this cluster's service network)
   instead of Traefik -- `cloudflared` logs showed
   `"Unable to reach the origin service... i/o timeout"` for hours. Fixed
   by pointing the route at `traefik.kube-system.svc.cluster.local:80`,
   then replaced entirely with a single wildcard route
   (`*.spicyfajitas.com` -> Traefik) so no per-app tunnel config is ever
   needed again -- Traefik's own Ingress Host-header routing handles
   everything from there.
