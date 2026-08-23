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

# magic-temp-cloud (DOKS) was the temporary cluster used during the
# 2026-07 cross-country move -- see kubernetes/magic-cloud-temp-teardown.md.
# Deleted 2026-08 directly via the DO console (cost), not through that
# doc's terraform destroy step, so state was reconciled after the fact
# with `terraform state rm`. Cutover back to k3s confirmed working
# (magic/homepage/grafana all serving) before this block was removed.
