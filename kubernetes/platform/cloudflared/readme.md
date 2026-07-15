# cloudflared

Routes public internet traffic into the cluster without exposing the
router/port-forwarding. Points at Traefik (`kube-system/traefik:80`), not
at any specific app -- Traefik's own Ingress Host-based routing decides
where a request actually goes, so exposing a new app never touches this
component.

## 1. Create the tunnel (Cloudflare dashboard)

1. Cloudflare dashboard -> **Zero Trust** -> **Networks** -> **Tunnels** ->
   **Create a tunnel**
2. Connector type: **Cloudflared**
3. Name it something identifiable, e.g. `k3s-homelab`
4. On the "Install and run a connector" step, skip the install command --
   just copy the **token** shown (the long string after `--token`, not the
   whole command). That's what goes in the Secret below.
5. **Public Hostname** tab, add **one** wildcard route -- this is the only
   route ever needed, for every app, forever:
   - **Subdomain/domain**: `*` / `spicyfajitas.com`
   - **Service**: `HTTP` -> `traefik.kube-system.svc.cluster.local:80`

   (Originally set up per-app instead of wildcard -- that caused a real,
   multi-hour debugging session during the `magic` cutover, see
   `kubernetes/apps/magic/readme.md`'s "DNS/tunnel debugging story". Don't
   repeat that; one wildcard route is simpler and correct.)

## 2. Secret

SOPS-encrypted and checked into git as of 2026-07
(`secrets/cloudflare-tunnel-token.sops.yaml`) -- see
`kubernetes/platform/sops-secrets-operator/readme.md` for how that works.
To (re)populate it with the real value:

```bash
sops kubernetes/platform/cloudflared/secrets/cloudflare-tunnel-token.sops.yaml
kubectl apply -f kubernetes/platform/cloudflared/secrets/cloudflare-tunnel-token.sops.yaml
```

## 3. Deploy

```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-deployment.yaml
kubectl -n cloudflared rollout status deployment/cloudflared
```

## Verify

```bash
kubectl -n cloudflared logs deploy/cloudflared --tail=30
```

Should show `Registered tunnel connection`. Then hit any
`*.spicyfajitas.com` hostname with a matching Ingress from *outside* the
LAN (phone on cellular, not wifi) to confirm it's actually routing through
Cloudflare's edge and not just working because you're on the same network
as Traefik's LAN IP.

## Status

- `magic.spicyfajitas.com` cut over from DigitalOcean to this tunnel,
  2026-07 -- see `kubernetes/apps/magic/readme.md`.
- 1 replica (down from an original 2) -- each replica is its own connector
  in the Cloudflare dashboard, and running 2 was more dashboard noise than
  redundancy was worth for a personal app. Bump back up if that tradeoff
  changes.
- Secrets now SOPS-encrypted in git (`kubernetes/platform/sops-secrets-operator/`),
  no longer manual-create-only.
