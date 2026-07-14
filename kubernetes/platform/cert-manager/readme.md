# cert-manager

Installed via the official Helm chart (jetstack/cert-manager), pinned
version, values file checked in (`values.yaml`) rather than passed as
`--set` flags on the CLI, so the exact config actually installed lives in
git:

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update jetstack

KUBECONFIG=~/.kube/k3s-homelab.yaml kubectl apply -f 00-namespace.yaml

KUBECONFIG=~/.kube/k3s-homelab.yaml helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.21.0 \
  -f values.yaml \
  --wait --timeout 180s
```

## Secret (not in git, not codified -- created manually)

The `ClusterIssuer` (`01-clusterissuer.yaml`) needs a Cloudflare API token
(`Zone:Read` + `DNS:Edit`) as a Secret in the `cert-manager` namespace
*before* it's applied:

```bash
KUBECONFIG=~/.kube/k3s-homelab.yaml kubectl create secret generic cloudflare-api-token \
  --namespace cert-manager \
  --from-literal=api-token=<token>
```

Deliberately not a manifest in this repo -- no Sealed Secrets/SOPS yet (see
`.claude-plan.md`'s "No secrets management" gap), so there's no safe way to
commit it. Once that's in place, this Secret should move into git as a
SealedSecret.

## Apply

```bash
KUBECONFIG=~/.kube/k3s-homelab.yaml kubectl apply -f 01-clusterissuer.yaml
```

Verify: `kubectl get clusterissuer letsencrypt-dns` should show `READY: True`.

## Upgrading

```bash
helm repo update jetstack
KUBECONFIG=~/.kube/k3s-homelab.yaml helm upgrade cert-manager jetstack/cert-manager \
  --namespace cert-manager -f values.yaml --version <new-version>
```
