# external-dns

Single instance, Cloudflare provider, watching `service` and `ingress`
sources -- auto-creates DNS records for anything opted in, instead of
hand-editing Cloudflare's dashboard. `domainFilters` in `values.yaml`
scopes it to `spicyfajitas.com` only, even though the Cloudflare token
itself has "all zones" access (see
`kubernetes/platform/cert-manager/readme.md`) -- that filter is the actual
safety boundary, not the token's scope.

**Opt-in only** (`annotationFilter: "external-dns-managed=true"` in
`values.yaml`): an Ingress/Service is only touched if it carries
`external-dns-managed: "true"` as an annotation. Nothing is managed by
default. Found out the hard way (2026-07) that there's no reliable
per-resource "exclude me" annotation in this chart/version -- opt-in via
`annotationFilter` is the real, documented mechanism. Anything meant to be
reached through the cloudflared tunnel (`kubernetes/platform/cloudflared/`)
should specifically **not** opt in -- the tunnel's own Public Hostname
config owns that DNS, and having both fight over the same record is how a
very confusing debugging session happened (external-dns silently
recreating a manually-deleted record every ~1 minute looked exactly like,
and got mistaken for, Cloudflare-side DNS unreliability).

## Secret

Same Cloudflare API token as `kubernetes/platform/cert-manager/`, but
Secrets are namespace-scoped, so it needs its own copy here. SOPS-encrypted
and checked into git as of 2026-07
(`secrets/cloudflare-api-token.sops.yaml`) -- see
`kubernetes/platform/sops-secrets-operator/readme.md` for how that works.
To (re)populate it with the real value:

```bash
sops kubernetes/platform/external-dns/secrets/cloudflare-api-token.sops.yaml
kubectl apply -f kubernetes/platform/external-dns/secrets/cloudflare-api-token.sops.yaml
```

## Install

```bash
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/ --force-update
helm repo update external-dns

kubectl apply -f 00-namespace.yaml

helm install external-dns external-dns/external-dns \
  --namespace external-dns \
  --version 1.21.1 \
  -f values.yaml \
  --wait --timeout 180s
```

## The `crd` source

`sources` includes `crd` in addition to `service`/`ingress` -- lets a plain
`DNSEndpoint` object declare an exact DNS record with no backing
Ingress/Service. Used for exactly one thing right now: the
`*.spicyfajitas.com` wildcard tunnel record
(`kubernetes/platform/cloudflared/02-wildcard-dns.yaml`). Same
`annotationFilter` opt-in applies to it (needs
`external-dns-managed: "true"` on the `DNSEndpoint` itself).

## Opting an Ingress/Service in

```yaml
metadata:
  annotations:
    external-dns-managed: "true"
    # un-proxied ("DNS only") record, for genuinely internal-only names
    # that should resolve to a private LAN IP -- see .claude-plan.md's DNS
    # backend decision. Omit entirely (defaults to proxied) for anything
    # meant to be reachable from the public internet.
    external-dns.alpha.kubernetes.io/cloudflare-proxied: "false"
```

## Verify

```bash
kubectl -n external-dns logs deploy/external-dns --tail=50
```

Should show it discovering the Cloudflare zone and, once something is
opted in, reconciling records for it -- and *only* for opted-in resources.

## Upgrading

```bash
helm repo update external-dns
helm upgrade external-dns external-dns/external-dns \
  --namespace external-dns -f values.yaml --version <new-version>
```
