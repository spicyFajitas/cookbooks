# magic (EDHRec Deck Analyzer)

k3s deployment of `spicyFajitas/magic` -- moved on-site from DigitalOcean,
per `.claude-plan.md`'s k3s buildout, since it's the top-priority
production app now. Source repo: `/Users/adam/Documents/code/magic`
locally, `ghcr.io/spicyfajitas/edhrec-deck-analyzer` for the built image.

## What's here

Plain manifests (no Kustomize/Helm yet -- revisit once Argo CD adoption,
`.claude-plan.md` step 9, is actually underway):

- `00-namespace.yaml`
- `01-pvc.yaml` -- `cache/` and `output/` from the app, on k3s's built-in
  `local-path` StorageClass. Fine for a single-node cluster; move to NFS
  (TrueNAS, per the storage plan) if this ever needs to survive a node
  rebuild or scale beyond one replica. Losing this data isn't a real
  incident either way -- it's just re-fetched from EDHRec/Scryfall.
- `02-deployment.yaml` -- 1 replica (RWO PVCs + a UI don't benefit from HA
  here), health probes on Streamlit's built-in `/_stcore/health`.
- `03-service.yaml` -- `NodePort` for both the web UI (`:30851`) and
  Prometheus metrics (`:30852`). Temporary: once cloudflared/cert-manager/
  external-dns land, `web` should become a plain `ClusterIP` behind an
  Ingress; `metrics` should stay reachable the same way it is now, since
  the scraper (existing homelab Prometheus) lives outside the cluster.

Numeric prefixes are load-bearing -- `kubectl apply -f kubernetes/apps/magic/`
applies files in alphabetical order, and the namespace has to exist before
anything else can be created in it.

## Deploy / update

```bash
export KUBECONFIG=~/.kube/k3s-homelab.yaml   # see kubernetes/readme.md
kubectl apply -f kubernetes/apps/magic/
kubectl -n magic rollout status deployment/edhrec-analyzer
```

New image pushed to `ghcr.io`? Nothing auto-deploys it (no image-updater
controller, no CI step that can reach the cluster) -- pick it up with:

```bash
kubectl -n magic rollout restart deployment/edhrec-analyzer
```

## Known issue: metrics don't start until someone loads the page

Found while wiring this up, not fixed here since it's an app-code issue in
the `magic` repo, not this one: `web_app.py` starts the Prometheus metrics
server (`start_http_server(8502)`) inside an `@st.cache_resource`-decorated
function called at module level. That only actually *executes* the first
time Streamlit runs the script for a real session -- which needs a real
WebSocket client (an actual browser), not just an HTTP GET. Confirmed via
`kubectl -n magic exec deployment/edhrec-analyzer -- cat /proc/net/tcp`:
port 8501 listens immediately, 8502 doesn't show up until you actually open
the app in a browser tab.

Practically: `/_stcore/health` (Streamlit's own endpoint) is up right away,
so the pod passes its liveness/readiness probes fine -- but the Prometheus
scrape job (`magic-edhrec-analyzer` in
`ansible/roles/docker_services/templates/grafana/prometheus.yml.j2`) will
show the target as down until someone visits <http://10.100.10.12:30851>
(or the real domain, once that's wired up) at least once after each pod
restart. Fix belongs in the `magic` repo -- move the `start_http_server`
call out of the `st.cache_resource`-gated function so it runs
unconditionally at import time, same as the logging config a few lines
above it.

## Monitoring

- Prometheus scrape target: see the note in `prometheus.yml.j2` above.
  Applied automatically next time the `grafana` docker_service tag runs
  (`ansible-playbook site.yml --tags grafana`).
- Grafana dashboard: `ansible/roles/docker_services/files/edhrec-grafana-dashboard.json`,
  copied from the magic repo. Import manually (Grafana -> Dashboards ->
  Import) -- see that file's neighboring `files/README.md`.

## Not done yet

- Real external access (`magic.spicyfajitas.com` pointing here instead of
  DigitalOcean) needs cloudflared + external-dns + cert-manager
  (`.claude-plan.md` steps 5-7) or, as a faster interim step, reusing
  whatever Cloudflare Tunnel already routes that domain today and pointing
  it at this cluster's `edhrec-analyzer` Service instead of the DO droplet.
  Needs the existing tunnel token, which nobody's supplied yet.
- MetalLB (so `web`/future Ingress get a stable LAN IP instead of a
  NodePort).
