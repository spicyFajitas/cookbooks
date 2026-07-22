# Fresh DOKS cluster setup (magic-temp-cloud)

Simple step-by-step for bootstrapping the temporary cloud cluster from
scratch. Needed whenever the cluster gets rebuilt (node pool
destroy+recreate wipes everything, not just the node -- happened twice
during the 2026-07 move). Companion to
`kubernetes/magic-cloud-temp-teardown.md` (the reverse direction, cutting
back to k3s and tearing this down).

Run everything against the `do-nyc3-magic-temp-cloud` kubectl context.
Confirm you're on it before each step:

```bash
kubectl config current-context
# if not do-nyc3-magic-temp-cloud:
doctl kubernetes cluster kubeconfig save magic-temp-cloud
```

## 1. Traefik

DOKS has no built-in ingress controller (unlike k3s's bundled Traefik) --
installed the same way so every Ingress in this repo
(`ingressClassName: traefik`) works unchanged. Goes in `kube-system`
specifically, not its own namespace -- the shared Cloudflare Tunnel's
routing config is hardcoded to `traefik.kube-system.svc.cluster.local`.

```bash
helm repo add traefik https://traefik.github.io/charts --force-update
helm install traefik traefik/traefik \
  --namespace kube-system \
  --set service.type=LoadBalancer \
  --wait --timeout 240s
```

## 2. cert-manager

```bash
cd kubernetes/platform/cert-manager
helm repo add jetstack https://charts.jetstack.io --force-update
kubectl apply -f 00-namespace.yaml
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.21.0 \
  -f values.yaml \
  --wait --timeout 240s

# secret + ClusterIssuer (reuses the same encrypted token as k3s, no
# second copy needed)
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
TOKEN=$(sops -d --extract '["spec"]["secretTemplates"][0]["stringData"]["api-token"]' secrets/cloudflare-api-token.sops.yaml)
kubectl create secret generic cloudflare-api-token --namespace cert-manager --from-literal=api-token="$TOKEN"
kubectl apply -f 01-clusterissuer.yaml
kubectl get clusterissuer letsencrypt-dns   # should show READY True within a few seconds
cd ../../..
```

## 3. sops-secrets-operator

Reuses the exact same `age` key as k3s -- this is the whole reason SOPS
was chosen over Sealed Secrets originally: one key, portable across any
cluster.

```bash
kubectl create namespace sops-secrets-operator
kubectl create secret generic sops-age-key \
  --namespace sops-secrets-operator \
  --from-file=keys.txt=$HOME/.config/sops/age/keys.txt

helm repo add sops-secrets-operator https://isindir.github.io/sops-secrets-operator/ --force-update
helm install sops-secrets-operator sops-secrets-operator/sops-secrets-operator \
  --namespace sops-secrets-operator \
  --version 0.28.0 \
  -f kubernetes/platform/sops-secrets-operator/values.yaml \
  --wait --timeout 180s
```

## 4. metrics-server

Not built into DOKS by default either (`kubectl top` won't work without
it). `--kubelet-insecure-tls` is needed on DOKS specifically.

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ --force-update
helm install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={--kubelet-insecure-tls} \
  --wait --timeout 120s
```

## 5. Argo CD

```bash
cd kubernetes/platform/argocd
kubectl apply -f 00-namespace.yaml
helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm install argocd argo/argo-cd \
  --namespace argocd \
  --version 10.1.4 \
  -f values.yaml \
  --wait --timeout 300s
cd ../../..
```

## 6. Bootstrap GitOps

One command pulls in everything else -- cert-manager's ClusterIssuer,
external-dns, cloudflared, image-updater, monitoring (Prometheus/Grafana/Loki),
`magic`, and `homepage`:

```bash
kubectl apply -f kubernetes/argocd-apps/root.yaml
```

Give it a couple minutes, then check:

```bash
kubectl -n argocd get application
```

Everything should settle to `Synced`/`Healthy` on its own (root itself
staying `OutOfSync` is a known cosmetic quirk, not a real problem). A few
things will show `CreateContainerConfigError` or sit `Pending` until step 7
below -- expected, their secrets aren't applied yet.

## 7. Manual secrets

These can't come from git automatically (deliberately -- see each
platform component's own readme for why), so they need one apply each,
by hand, every time the cluster is rebuilt:

```bash
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

# external-dns's Cloudflare token (plain secret, same value as cert-manager's)
TOKEN=$(sops -d --extract '["spec"]["secretTemplates"][0]["stringData"]["api-token"]' kubernetes/platform/external-dns/secrets/cloudflare-api-token.sops.yaml)
kubectl create secret generic cloudflare-api-token --namespace external-dns --from-literal=api-token="$TOKEN"

# cloudflared's tunnel token (SAME tunnel as k3s -- toggling which
# cluster's connector is active, not a second tunnel)
kubectl apply -f kubernetes/platform/cloudflared/secrets/cloudflare-tunnel-token.sops.yaml

# homepage's vars
kubectl apply -f kubernetes/apps/homepage/secrets/homepage-vars.sops.yaml
```

If a `SopsSecret` doesn't produce a real `Secret` within ~30s, the
operator's watch missed the create event (a known quirk, not a config
problem) -- force it:

```bash
kubectl -n sops-secrets-operator rollout restart deployment/sops-secrets-operator
```

## 8. Connector check

A fresh `cloudflared` deployment starts at `replicas: 1` by default (no
override needed) -- but if k3s's connector is ever also up at the same
time, scale one of them to 0 first. Never have both running -- same tunnel,
they'll load-balance traffic unpredictably between two different clusters.

```bash
kubectl -n cloudflared logs deploy/cloudflared --tail=20
# should show "Registered tunnel connection", no origin errors
```

## 9. Verify

```bash
curl -s -o /dev/null -w "magic: HTTP %{http_code}\n" \
  --resolve magic.spicyfajitas.com:443:104.21.34.95 https://magic.spicyfajitas.com/
curl -s -o /dev/null -w "homepage: HTTP %{http_code}\n" \
  --resolve homepage.spicyfajitas.com:443:104.21.34.95 https://homepage.spicyfajitas.com/
curl -s -o /dev/null -w "grafana: HTTP %{http_code}\n" \
  --resolve homelab-grafana.spicyfajitas.com:443:104.21.34.95 https://homelab-grafana.spicyfajitas.com/
```

`magic`/`homepage` -> `200`. `grafana` -> `302` is correct (redirect to
its own login page, not an error).

## Known gotchas already fixed in the manifests (nothing to do, just context)

- PVCs (`magic`, `monitoring`'s Prometheus/Grafana, Loki) don't hardcode a
  `storageClassName` -- each cluster picks its own default automatically
  (`local-path` on k3s, `do-block-storage` on DOKS).
- Prometheus/Grafana set `securityContext.fsGroup` explicitly -- without
  it, DOKS's real block-storage CSI driver enforces normal Unix ownership
  and both pods crash-loop on a permission error that k3s's more
  permissive `local-path` never surfaced.
- `kubernetes/argocd-apps/apps-appset.yaml` has `ignoreApplicationDifferences`
  for `/spec/source/kustomize/images` -- without it, the ApplicationSet
  silently reverts every patch `argocd-image-updater` makes.
- `kubernetes/argocd-apps/platform-cloudflared.yaml` has
  `ignoreDifferences` for `spec.replicas` -- without it, Argo CD's
  adoption sync resets a manual connector-toggle scale-down back to 1,
  causing a dual-connector incident (both clusters' tunnels registered at
  once).
