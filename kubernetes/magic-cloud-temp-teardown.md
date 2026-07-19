# Coming home: cut back from DOKS to k3s

Context: `magic` and `homepage` were temporarily cut over to a DigitalOcean
Kubernetes (DOKS) cluster during a cross-country move, 2026-07, while the
on-prem k3s server was packed up and unreachable. DOKS ended up running a
**full GitOps replica** of the platform (Argo CD, cert-manager,
external-dns, sops-secrets-operator, Traefik, plus `magic` and
`homepage`), not just a one-off app deploy -- same manifests, same repo,
both clusters self-managing. This is the reverse of that cutover.

**Same Cloudflare Tunnel throughout, not a second one.** The original plan
was a dedicated new tunnel for DOKS, but the token pasted in turned out to
be the *existing* homelab tunnel's -- rather than create a new one, the
call was made to just toggle which cluster's `cloudflared` connector is
active on the one tunnel. `kubernetes/argocd-apps/platform-cloudflared.yaml`
has an `ignoreDifferences` block on `spec.replicas` specifically so Argo
CD never fights that manual toggle on either cluster (found the hard way:
its first adoption sync silently reset a `kubectl scale --replicas=0`
back to 1, causing a real live dual-connector incident -- both clusters'
connectors registered on the same tunnel simultaneously, load-balancing
`magic`/`homepage` traffic unpredictably between them until caught). Leave
that `ignoreDifferences` block in place permanently -- it's not
DOKS-specific, it's what makes this kind of active/standby toggle safe on
*any* cluster sharing this tunnel in the future.

## 1. Verify k3s is actually healthy before cutting anything

Don't cut the connector back until the on-prem side is confirmed good --
otherwise this just trades one outage for another.

```bash
kubectl --context k3s get nodes
kubectl --context k3s -n argocd get application
```

All nodes `Ready`, all Applications `Synced`/`Healthy` (or at least
`Healthy` -- `root` itself sitting `OutOfSync` is a known cosmetic
self-reference quirk, not a real problem, see `kubernetes/argocd-apps/readme.md`
if that's not already documented there). If anything's actually
unhealthy, fix that first.

## 2. Cut the connector back

```bash
# DOKS down first
kubectl --context do-nyc3-magic-temp-cloud -n cloudflared scale deployment/cloudflared --replicas=0
kubectl --context do-nyc3-magic-temp-cloud -n cloudflared get pods   # confirm empty

# then k3s up
kubectl --context k3s -n cloudflared scale deployment/cloudflared --replicas=1
kubectl --context k3s -n cloudflared rollout status deployment/cloudflared --timeout=60s
```

Same order as the original cutover (whichever side is going *down* first,
always) -- never have both scaled up at once.

## 3. Verify from outside, not just kubectl

DNS resolution alone doesn't prove which cluster is actually serving
traffic -- check the real HTTP response, and don't trust `curl` on a
machine that might have Tailscale/local split-DNS intercepting queries
(this bit the original homepage migration's debugging -- see
`kubernetes/apps/homepage/readme.md` if that history is written up).
DNS-over-HTTPS bypasses that:

```bash
curl -s "https://cloudflare-dns.com/dns-query?name=magic.spicyfajitas.com&type=A" \
  -H "accept: application/dns-json"

curl -s -o /dev/null -w "magic: HTTP %{http_code}\n" \
  --resolve magic.spicyfajitas.com:443:104.21.34.95 https://magic.spicyfajitas.com/
curl -s -o /dev/null -w "homepage: HTTP %{http_code}\n" \
  --resolve homepage.spicyfajitas.com:443:104.21.34.95 https://homepage.spicyfajitas.com/
```

Both `HTTP 200`. Also check `kubectl --context k3s -n cloudflared logs
deploy/cloudflared --since=2m` for a clean connection with no origin
errors, same as the outbound cutover's own verification.

## 4. Tear down DOKS

```bash
cd terraform/digital_ocean
terraform destroy -target=digitalocean_kubernetes_cluster.magic_temp
```

This also destroys the DigitalOcean Load Balancer Traefik provisioned
(owned by the cluster's cloud-controller-manager, goes with it) and both
worker nodes (a 2nd node was added mid-trip after the original single
`s-1vcpu-2gb` node hit 206% memory *limit* overcommit and real 93% usage
running the full platform stack -- see this file's git history / the
`node_pool` block's own comment in `main.tf` for that story).

Then remove the `digitalocean_kubernetes_cluster.magic_temp` resource
block from `terraform/digital_ocean/main.tf` entirely, so it doesn't
linger as a stale, no-longer-real resource the way `uptime_kuma`
previously did in the same file.

**Not destroyed, and shouldn't be:**

- `kubernetes/apps/magic/01-pvc.yaml`'s removed `storageClassName` --
  this was a genuine portability fix (works on any cluster's own default
  StorageClass), not a DOKS-specific hack. Keep it as-is.
- `platform-cloudflared.yaml`'s `ignoreDifferences` block -- see the top
  of this doc, it's a permanent safety fix.
- magic's `cache`/`output` data on DOKS -- gets destroyed along with the
  cluster, and that's fine, same reasoning as always: cache just avoids
  redundant EDHRec/Scryfall calls, output regenerates on next run.

## 5. Loose ends

- `homepage`'s widgets that depend on LAN IPs (Proxmox, TrueNAS, Plex,
  Speedtest Tracker) were expected to show broken/empty on DOKS the whole
  time -- DOKS has no path back to the `10.100.10.x` LAN. Not a bug,
  nothing to fix, just confirm they're back to rendering real data now
  that `homepage` is on k3s again.
- Double check nothing else got pointed at the temporary cluster's
  context in the meantime (`kubectl config get-contexts` --
  `do-nyc3-magic-temp-cloud` should simply stop resolving once the
  cluster's destroyed; safe to `kubectl config delete-context
  do-nyc3-magic-temp-cloud` for cleanliness).
