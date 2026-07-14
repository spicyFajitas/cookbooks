# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "web_application" {
    backups              = true
    image                = "ubuntu-22-04-x64"
    ipv6                 = false
    monitoring           = true
    name                 = "uptime-kuma"
    region               = "nyc1"
    resize_disk          = true
    size                 = "s-1vcpu-512mb-10gb"
    # Each tag becomes the exact Ansible group name this droplet is placed
    # in by the dynamic inventory (ansible/inventory/digital_ocean.yml).
    tags                 = ["terraform", "uptime_kuma"]
}
