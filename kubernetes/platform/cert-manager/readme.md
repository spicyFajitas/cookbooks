# cert-manager

Installed via the official Helm chart (jetstack/cert-manager), pinned
version, values file checked in (`values.yaml`) rather than passed as
`--set` flags on the CLI, so the exact config actually installed lives in
git:

```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update jetstack

kubectl apply -f 00-namespace.yaml

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.21.0 \
  -f values.yaml \
  --wait --timeout 180s
```

## Secret

The `ClusterIssuer` (`01-clusterissuer.yaml`) needs a Cloudflare API token
(`Zone:Read` + `DNS:Edit`) as a Secret in the `cert-manager` namespace
*before* it's applied. SOPS-encrypted and checked into git as of 2026-07
(`secrets/cloudflare-api-token.sops.yaml`) -- see
`kubernetes/platform/sops-secrets-operator/readme.md` for how that works.
To (re)populate it with the real value:

```bash
sops kubernetes/platform/cert-manager/secrets/cloudflare-api-token.sops.yaml
# edit the api-token value, save, quit -- re-encrypts automatically
kubectl apply -f kubernetes/platform/cert-manager/secrets/cloudflare-api-token.sops.yaml
```

## Apply

```bash
kubectl apply -f 01-clusterissuer.yaml
```

Verify: `kubectl get clusterissuer letsencrypt-dns` should show `READY: True`.

## Upgrading

```bash
helm repo update jetstack
helm upgrade cert-manager jetstack/cert-manager \
  --namespace cert-manager -f values.yaml --version <new-version>
```
