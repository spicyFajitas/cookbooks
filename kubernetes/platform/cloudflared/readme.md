# cloudflared

Routes public internet traffic into the cluster without exposing the
router/port-forwarding. Points at Traefik (`kube-system/traefik:80`), not
at any specific app -- Traefik's own Ingress Host-based routing decides
where a request actually goes, so exposing a new app later never touches
this component.

## 1. Create the tunnel (Cloudflare dashboard)

1. Cloudflare dashboard -> **Zero Trust** -> **Networks** -> **Tunnels** ->
   **Create a tunnel**
2. Connector type: **Cloudflared**
3. Name it something identifiable, e.g. `k3s-homelab`
4. On the "Install and run a connector" step, skip the install command --
   just copy the **token** shown (the long string after `--token`, not the
   whole command). That's what goes in the Secret below.
5. **Public Hostname** tab, add a route:
   - **Subdomain/domain**: `magic-k3s` / `spicyfajitas.com` (matches the
     staging validation hostname in `kubernetes/apps/magic/04-ingress.yaml`
     -- switch this to `magic` once that's validated and ready to cut over
     from DigitalOcean)
   - **Service**: `HTTP` -> `traefik.kube-system.svc.cluster.local:80`
   - Repeat this step (same Service target, different hostname) for any
     future app you want externally reachable -- Traefik routes by Host
     header from there, this tunnel doesn't need to know apps exist.

## 2. Secret

```bash
KUBECONFIG=~/.kube/k3s-homelab.yaml kubectl create secret generic cloudflare-tunnel-token \
  --namespace cloudflared \
  --from-literal=token=<the-connector-token-from-step-1.4>
```

## 3. Deploy

```bash
KUBECONFIG=~/.kube/k3s-homelab.yaml kubectl apply -f 00-namespace.yaml
KUBECONFIG=~/.kube/k3s-homelab.yaml kubectl apply -f 01-deployment.yaml
KUBECONFIG=~/.kube/k3s-homelab.yaml kubectl -n cloudflared rollout status deployment/cloudflared
```

## Verify

```bash
KUBECONFIG=~/.kube/k3s-homelab.yaml kubectl -n cloudflared logs deploy/cloudflared --tail=30
```

Should show `Registered tunnel connection` (x2, one per replica). Then hit
the hostname from step 1.5 from *outside* the LAN (phone on cellular, not
wifi) to confirm it's actually routing through Cloudflare's edge and not
just working because you're on the same network as Traefik's LAN IP.

## Not yet done

- Cut `magic.spicyfajitas.com` itself over from DigitalOcean to this tunnel
  (currently only the `magic-k3s` staging hostname routes here) -- do this
  only after the staging validation in `kubernetes/apps/magic/readme.md`
  passes and the Ingress is back on the production `letsencrypt-dns`
  ClusterIssuer, not staging.
- Sealed Secrets for `cloudflare-tunnel-token` and `cloudflare-api-token`
  (cert-manager, external-dns) -- all three are manual-create-only right
  now, not in git (`.claude-plan.md`'s "No secrets management" gap).
