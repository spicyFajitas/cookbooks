# Imported 2026-07-19 to match actual state after out-of-band config drift
# (previously-tracked droplet id 353961664 no longer exists; this droplet
# has been running unmanaged since 2025-12-13). Image is pinned by numeric
# id because "24.04 (LTS) x64" is now a retired image slug that DO no
# longer resolves by name for existing droplets.
resource "digitalocean_droplet" "web_application" {
    backups              = true
    image                = "195932981"
    ipv6                 = false
    monitoring           = false
    name                 = "ubuntu-s-1vcpu-512mb-10gb-nyc3-01"
    region               = "nyc3"
    resize_disk          = true
    size                 = "s-1vcpu-1gb"
    # No tags currently applied (drift) -- was previously
    # ["terraform", "uptime_kuma"] for Ansible dynamic-inventory grouping.
    tags                 = []
}

# Temporary cloud cluster while the on-prem k3s cluster is unreachable
# during a cross-country move, 2026-07 -- grew from "just magic" into a
# full GitOps replica of the whole platform (Argo CD, cert-manager,
# external-dns, sops-secrets-operator, Traefik, magic, homepage), same
# manifests/repo as k3s. Meant to be torn down once back home -- see
# kubernetes/magic-cloud-temp-teardown.md for the full cutover-back +
# destroy sequence, not a permanent resource.
resource "digitalocean_kubernetes_cluster" "magic_temp" {
  name    = "magic-temp-cloud"
  region  = "nyc3"
  version = "1.36.0-do.3"

  # Single bigger node (2026-07), not multiple small ones -- explicit call
  # after real `kubectl top` data showed 2x and then 3x s-1vcpu-2gb nodes
  # all under real pressure (90-105% CPU) running this stack (full Argo CD
  # + cert-manager + external-dns + sops-secrets-operator + Traefik +
  # metrics-server + magic + homepage), one of which got auto-recycled by
  # DigitalOcean mid-trip and caused a real, live 502/503 outage. Same
  # monthly cost as the 2-node setup ($24/mo), simpler single-node
  # architecture instead of horizontal spread.
  # s-2vcpu-8gb-amd (2026-07): resized the underlying droplet directly via
  # `doctl compute droplet-action resize` (power off, resize, power on) at
  # the user's explicit direction, specifically to avoid another
  # destroy+recreate cycle through terraform's node_pool size handling.
  # Real consequence found immediately after: DOKS's own node pool record
  # doesn't know about droplet-level resizes done outside its own node
  # pool API -- it kept re-cordoning the node as a spec mismatch
  # (`node.kubernetes.io/unschedulable` taint reappearing every ~90s,
  # `doctl kubernetes cluster node-pool get` still reporting the old
  # s-2vcpu-4gb size) until this value here caught up to match. Confirmed
  # via `terraform plan` before applying that this reconciles state only,
  # doesn't trigger a destroy+recreate on top of the already-completed
  # manual resize.
  node_pool {
    name       = "magic-temp-pool"
    size       = "s-2vcpu-8gb-amd"
    node_count = 1
  }

  tags = ["terraform", "magic_temp_cloud"]
}
