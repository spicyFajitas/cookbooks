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

  # 2 nodes, not 1 (2026-07): scope grew from "just magic" to a full
  # GitOps replica (Argo CD, cert-manager, external-dns, sops-secrets-operator,
  # Traefik, magic, homepage) -- a single s-1vcpu-2gb node hit 206% memory
  # *limit* overcommit and real observed 93% usage. Adding a second node
  # instead of resizing the existing one: no downtime to add it, and avoids
  # a single point of failure for the whole temporary cluster while it's
  # meant to run unattended during the move.
  node_pool {
    name       = "magic-temp-pool"
    size       = "s-1vcpu-2gb"
    node_count = 2
  }

  tags = ["terraform", "magic_temp_cloud"]
}
