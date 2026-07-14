# App template

Copy this directory to scaffold a new app.

## 1. Copy and rename

```bash
cp -r kubernetes/apps/_template kubernetes/apps/<name>
cd kubernetes/apps/<name>

# macOS:
sed -i '' "s/APP_NAME/<name>/g" *.yaml
# Linux:
sed -i "s/APP_NAME/<name>/g" *.yaml
```

## 2. Edit what's actually app-specific

- `deployment.yaml`: `image`, `containerPort`, resource requests/limits
- `service.yaml`: `port`/`targetPort` to match
- `ingress.yaml`: hostname, if not `<name>.spicyfajitas.com`

That's it for a basic HTTP app with no state. Validate it renders before
applying:

```bash
kubectl kustomize kubernetes/apps/<name>/
```

## 3. Anything beyond the basics

Not every app needs these -- add only what applies. `kubernetes/apps/magic/`
is a real example of most of them:

- **Persistent storage**: a `PersistentVolumeClaim` + `volumeMounts`/`volumes`
  on the Deployment (see `magic/01-pvc.yaml` and its Deployment's `volumes:`)
- **A second port** (e.g. Prometheus metrics) that needs its own Service
  type (see `magic/03-service.yaml`'s `edhrec-analyzer-metrics`, a NodePort
  alongside the main ClusterIP) -- if the homelab Prometheus should scrape
  it, also add a job to
  `ansible/roles/docker_services/templates/grafana/prometheus.yml.j2`
- **Health probes**: uncomment/add `livenessProbe`/`readinessProbe` in
  `deployment.yaml` once you know the app's health endpoint
- **An internal-only hostname** (not through the tunnel) or one that needs
  its own DNS record instead of relying on the wildcard route: opt into
  external-dns -- see `kubernetes/platform/external-dns/readme.md`'s
  "Opting an Ingress/Service in"

## 4. Apply

```bash
export KUBECONFIG=~/.kube/k3s-homelab.yaml
kubectl apply -k kubernetes/apps/<name>/
kubectl -n <name> rollout status deployment/<name>
```

Once Argo CD is set up (`kubernetes/platform/argocd/`), this step goes
away -- merging to main is enough; Argo CD picks up any new directory
under `kubernetes/apps/` automatically (see
`kubernetes/argocd-apps/apps-appset.yaml`), except `_template` itself,
which is excluded.
