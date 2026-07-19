# monitoring (Prometheus + Grafana + pve-exporter)

k3s migration of the `grafana` docker_service on `docker-host`
(`ansible/roles/docker_services/`) -- part of the broader "gradually
transition everything from Docker to k3s" goal. Migrated 2026-07. Now the
last service in that ansible role too (`homepage` migrated first).

LAN-only, same as the docker-compose version -- no Ingress, no public
hostname. Deliberately kept that way: there's already a *separate*,
unrelated `grafana.spicyfajitas.com` Cloudflare Tunnel route pointing at a
different, cloud-hosted Grafana (see `kubernetes/platform/cloudflared/`'s
tunnel config) -- this instance has never been tunnel-exposed and giving it
a hostname risks colliding with that.

## What's here

- `00-namespace.yaml`
- `01-prometheus.yaml` -- ConfigMap (`prometheus.yml`) + PVC (10Gi,
  30d retention) + Deployment + Service. Scrape targets: itself, Proxmox
  (via `pve-exporter`, now an in-cluster Service instead of docker-host's
  IP:port), and `magic` (unchanged, same NodePort target as before).
  Dropped from the original config: the `docker-host` job (node_exporter
  monitoring docker-host itself -- docker-host is going away soon, not
  worth preserving) and `extra.yml.j2`'s `calcguard` job (confirmed dead
  even in the docker-compose version -- rendered to disk but never
  actually mounted into the prometheus container, never really scraped).
- `02-pve-exporter.yaml` -- Deployment + Service. Its whole config
  (`pve.yml`) is just the Proxmox API token, so it lives entirely in the
  Secret (`secrets/pve-token.sops.yaml`) rather than splitting token vs.
  non-secret config across a ConfigMap + Secret.
- `03-grafana.yaml` -- ConfigMap (datasource + dashboard-provider configs)
  + PVC (1Gi) + Deployment + NodePort Service (`:30300`).
- `04-dashboard-configmap.yaml` -- the EDHRec dashboard JSON, copied from
  `ansible/roles/docker_services/files/edhrec-grafana-dashboard.json`
  (itself from the magic app's own repo). **Now auto-provisioned** --
  the docker-compose version required manually clicking through Grafana's
  UI to import it (see that file's neighboring `files/README.md`); here it
  loads automatically on every start via `03-grafana.yaml`'s
  `dashboard-provider.yaml`. Re-copy from the magic repo by hand if it's
  updated there -- no sync automation for that.
  - The dashboard's "App Logs" panel (datasource `uid: loki`) won't work --
    this migration doesn't include Loki (out of scope, see
    `.claude-plan.md`'s "No observability yet" note). Every
    Prometheus-backed panel works fully.
  - Datasource `uid` is deliberately `mimir`, not `prometheus` -- the
    dashboard JSON hardcodes that uid on every panel (carried over as-is
    from the magic repo's own provisioning setup), so the provisioned
    datasource matches it rather than the dashboard being edited.

## Secret

One value moves from `ansible/roles/docker_services/vaults/production.yml`'s
`docker_services_secrets.grafana.pve_token_value` into a SOPS-encrypted
`SopsSecret` -- see `kubernetes/platform/sops-secrets-operator/readme.md`
for how the encrypt flow works. `secrets/pve-token.sops.yaml` currently has
a `REPLACE_WITH_REAL_VALUE` placeholder. To populate it:

```bash
sops kubernetes/platform/monitoring/secrets/pve-token.sops.yaml
# edit the token_value placeholder to the real value, save, quit
```

Won't decrypt cleanly on the first edit (no sops metadata yet on a
hand-written placeholder file) -- encrypt in place first if that happens:

```bash
sops --encrypt --in-place kubernetes/platform/monitoring/secrets/pve-token.sops.yaml
# then sops <file> again for any further edits
```

## Deploy / update

```bash
export KUBECONFIG=~/.kube/k3s-homelab.yaml
kubectl apply -k kubernetes/platform/monitoring/
kubectl apply -f kubernetes/platform/monitoring/secrets/pve-token.sops.yaml
kubectl -n monitoring rollout status deployment/prometheus
kubectl -n monitoring rollout status deployment/pve-exporter
kubectl -n monitoring rollout status deployment/grafana
```

Once committed and pushed, Argo CD's `platform-monitoring` Application
picks this up automatically (`kubernetes/argocd-apps/platform-monitoring.yaml`)
-- the `kubectl apply -k` step above goes away, but the `SopsSecret` still
needs applying by hand (or a first Argo CD sync), same as every other
secret in this repo.

Access Grafana at `http://<k3s-node-ip>:30300` -- first login is Grafana's
own default (`admin`/`admin`, forces a password change), same fresh-start
experience as any new Grafana install. Prometheus itself is ClusterIP-only
today (no direct LAN access) -- ordinarily reached through Grafana's
datasource; add a NodePort to `01-prometheus.yaml`'s Service if direct
access is ever needed.

## Cutover checklist

1. Apply everything above, populate the real `pve_token_value`, confirm
   Grafana loads at `:30300`, the Prometheus datasource works, and the
   EDHRec dashboard renders real data (except the Logs panel, expected).
2. Remove `grafana` from `ansible/roles/docker_services/tasks/main.yml`
   (the **only** remaining service there once this is done), delete
   `vars/grafana.yml` and `templates/grafana/`, and run `docker compose
   down` for it by hand on `docker-host`. At that point
   `ansible/roles/docker_services/` has no active services left -- worth
   deciding then whether to keep the role around (for reviving something
   later) or remove it entirely.
   Leave `docker_services_secrets.grafana` in the vault untouched, same
   reasoning as every other trimmed service.
