# traefik (k3s bundled Traefik overrides)

k3s installs and owns Traefik itself (`kube-system/helmchart/traefik`).
This directory doesn't install Traefik; it only holds a `HelmChartConfig`
that k3s merges over its own chart values. Argo CD syncs it via
`kubernetes/argocd-apps/platform-traefik.yaml` (`traefik-config`).

## What it turns on

- **JSON access logs** on stdout. Alloy already ships every pod's logs to
  Loki, so they're queryable in Grafana right away. Only these request
  headers are kept (everything else is dropped):
  `Cf-Connecting-Ip` (real visitor IP), `Cf-Ipcountry`, `User-Agent`,
  `Referer`. `ClientHost` is always the cloudflared pod's IP, because all
  public traffic arrives through the tunnel, so it isn't useful.
- **A `traefik-metrics` Service** (`:9100`) in front of the Prometheus
  metrics k3s already enables, scraped by the `traefik` job in
  `kubernetes/platform/monitoring/01-prometheus.yaml`.

Both feed the "Magic Traffic" Grafana dashboard
(`kubernetes/platform/monitoring/04-dashboard-configmap.yaml`).

## Applying a change

k3s's helm-controller watches HelmChartConfigs and re-runs the chart's
install job on change, which rolls the Traefik pod. To check:

```bash
export KUBECONFIG=~/.kube/k3s-homelab.yaml
kubectl -n kube-system get jobs | grep helm-install-traefik
kubectl -n kube-system get svc traefik-metrics
kubectl -n kube-system logs deploy/traefik --tail=5   # should be JSON lines
```

The Prometheus scrape job needs a Prometheus restart to load (no Reloader
yet; see `.claude-plan.md`):
`kubectl -n monitoring rollout restart deployment/prometheus`.

## Querying

```logql
# every request to magic, with the real visitor IP
{namespace="kube-system", container="traefik"} | json
  | ServiceName="magic-edhrec-analyzer-web@kubernetes"
```

Loki's json parser turns the `-` in header field names into `_`, so the
fields are `request_Cf_Connecting_Ip`, `request_Cf_Ipcountry`, and so on.

## Caveats

- Streamlit apps (magic) run over one long-lived websocket per browser
  session. Traefik sees the page load and the websocket upgrade, not each
  query, so per-query data comes from the app's own logs/metrics instead.
- k3s-only. `HelmChartConfig` doesn't exist on DOKS; exclude
  `traefik-config` there.
