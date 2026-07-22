# loki (+ Alloy)

Closes the last gap from the original monitoring migration: the EDHRec
dashboard's "App Logs" panel (`kubernetes/platform/monitoring/04-dashboard-configmap.yaml`)
has referenced a `loki` datasource since it was first copied from the
magic app's own repo, but nothing provided one until now.

## What's here

- `values.yaml` -- official `grafana/loki` chart, `SingleBinary`
  deployment mode (not the chart's default `SimpleScalable`/`Distributed`,
  which require object storage -- real overkill for a homelab). Local
  filesystem storage, no nginx gateway (nothing external needs to reach
  Loki directly, Grafana and Alloy both talk to it over ClusterIP). See
  the file's own comments for two real chart-enforced gotchas hit setting
  this up: `lokiCanary` can't be disabled (template validation hard-fails
  without it) and `write`/`read`/`backend` all default to `replicas: 3`
  regardless of `deploymentMode`, so `SingleBinary` mode requires
  explicitly zeroing those out or the chart also hard-fails.
- `02-alloy.yaml` -- ServiceAccount + ClusterRole + ClusterRoleBinding +
  ConfigMap (the actual `.alloy` config) + Deployment + Service. Ships
  container logs to Loki using `loki.source.kubernetes`, which tails logs
  through the Kubernetes API server (the same mechanism `kubectl logs`
  uses) instead of reading `/var/log/pods` directly off each node -- no
  hostPath mounts, no DaemonSet needed, works the same regardless of node
  count. `pods/log` (not just `pods`) is the RBAC permission that's easy
  to miss -- `pods` get/list/watch alone only sees metadata, actually
  reading log content needs that subresource explicitly.

`kubernetes/platform/monitoring/03-grafana.yaml`'s datasource
provisioning was updated alongside this -- `uid: loki` there matches what
the dashboard JSON already hardcodes, same reasoning as the `mimir` uid
for Prometheus.

## Deploy / update

```bash
export KUBECONFIG=~/.kube/k3s-homelab.yaml
helm repo add grafana https://grafana.github.io/helm-charts --force-update
helm install loki grafana/loki \
  --namespace monitoring \
  --version 6.28.0 \
  -f values.yaml \
  --wait --timeout 180s

kubectl apply -f 02-alloy.yaml
```

Once committed and pushed, Argo CD's `loki`/`loki-config` Applications
(`kubernetes/argocd-apps/platform-loki.yaml`) pick this up automatically.

## Verify

```bash
kubectl -n monitoring logs deploy/alloy --tail=50
```

Should show it discovering pods and pushing log entries with no errors.
Then in Grafana, either the EDHRec dashboard's "App Logs" panel should
start showing real `magic` container output, or query directly: Explore
-> Loki datasource -> `{namespace="magic"}`.
