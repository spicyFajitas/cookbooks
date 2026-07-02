# Proxmox Full-Clone
# ---
# Create a new VM from a clone

resource "proxmox_vm_qemu" "docker-host" {

    # VM General Settings
    target_node = "pve"
    vmid = "120"
    name = "docker-host"
    desc = "Description"

    # Tags drive Ansible's dynamic inventory grouping (ansible/inventory/pve.proxmox.yml):
    # each semicolon-separated tag here becomes the exact Ansible group name
    # this VM is placed in.
    tags = "docker_host;terraform"

    # VM Advanced General Settings
    onboot = true

    # VM OS Settings
    clone = "ubuntu-server-focal-docker"

    # VM System Settings
    agent = 1

    # VM CPU Settings
    cores = 1
    sockets = 1
    cpu = "host"

    # VM Memory Settings
    memory = 1024

    # VM Network Settings
    network {
        bridge = "vmbr0"
        model  = "virtio"
    }

    # VM Cloud-Init Settings
    os_type = "cloud-init"

    # (Optional) IP Address and Gateway
    # NOTE: this declares .59, but ansible/inventory/static.yml's docker_host
    # entry (docker-host-01) points at .20 -- Terraform state and the
    # Ansible-managed reality have drifted apart. Reconcile before treating
    # this resource as authoritative: either this IP is stale, or the real
    # host was never actually created by this Terraform config.
    ipconfig0 = "ip=10.100.10.59/24,gw=10.100.10.1"

    # (Optional) Default User
    # ciuser = "your-username"

    # (Optional) Add your SSH KEY
    # sshkeys = <<EOF
    # #YOUR-PUBLIC-SSH-KEY
    # EOF
}

# TODO: the self-hosted GitHub Actions runner VM (10.100.10.21, alias
# github-runner-01 in ansible/inventory/static.yml, role at
# ansible/roles/github_actions_runner) has no corresponding resource here --
# it was provisioned by hand. Import it (`terraform import`) or define a
# proxmox_vm_qemu resource for it, tagged `runner;terraform`, so it's
# reproducible instead of a one-off.
