# Ubuntu Server 
# ---
# Packer Template to create Ubuntu Server VM Tempalte with Docker on Proxmox

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "vm_name" {
    type = string
    default = "ubuntu-server-24.04"
}
variable "proxmox_api_url" {
    type = string
    default = env("PROXMOX_API_URL")
}

variable "proxmox_api_token_id" {
    type = string
    default = env("PROXMOX_API_TOKEN_ID")
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
    default = env("PROXMOX_API_TOKEN_SECRET")
}

variable "proxmox_node" {
    type = string
    default = "pve"
}

variable "proxmox_storage_pool" {
    type = string
    default = "storageSSD"
}

variable "ssh_username" {
    type = string
    default = "adam"
}

variable "ssh_private_key_file" {
    type = string
    default = "/home/adam/.ssh/id_ed25519"
}

variable "vm_description" {
    type = string
    default = "Ubuntu Server 24.04 Noble Numbat Image with Docker pre-installed\n\nTHERE IS NO PASSWORD SET ON THIS SERVER\n\nClone this VM, then set cloud init username and password.\n\nAlternatively, don't set username and password, then SSH to machine as ubuntu user, then sudo passwd to change password"
}

variable "vm_id" {
    type = string
    default = "9001"
}

variable "vm_iso_file" {
    type = string
    default = "local:iso/ubuntu-24.04-live-server-amd64.iso"
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server-24-04" {
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify = true

    # VM General Settings
    node = "${var.proxmox_node}"
    vm_id = "${var.vm_id}"
    vm_name = "${var.vm_name}"
    template_description = "${var.vm_description}"

    # ISO Settings
    # Option 1 is downloading via URL during Packer build
    // download via url
    // iso_url  = "https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso"
    // iso_checksum = "file:https://releases.ubuntu.com/24.04/SHA256SUMS"
    // iso_download_pve = true
    // task_timeout = "5m" // uploading can be slow
    # Option 2 is downloading in advance to Proxmox and referencing during build
    iso_file = "${var.vm_iso_file}"
    iso_storage_pool = "local"

    // additional_iso_files {
    //     cd_files = [
    //         "./http/meta-data",
    //         "./http/user-data"
    //     ]
    //     cd_label = "cidata"    
    //     iso_storage_pool = "local"
    // }

    unmount_iso = true

    qemu_agent = true

    scsi_controller = "virtio-scsi-single"

    disks {
        disk_size = "20G"
        format = "raw"
        storage_pool = "${var.proxmox_storage_pool}"
        type = "virtio"

        cache_mode = "writeback"
        io_thread = true
    }

    cpu_type = "kvm64"
    cores = "1"
    memory = "2048"

    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    }

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "${var.proxmox_storage_pool}"

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "10s"

    # PACKER Autoinstall Settings
    // http_interface = "wlp7s0"
    http_directory = "http"
    http_port_min = 8802
    http_port_max = 8810
        
    ssh_username = "${var.ssh_username}"
    ssh_private_key_file = "${var.ssh_private_key_file}"
    # Raise the timeout, when installation takes longer
    ssh_timeout = "10m"
}

build {

    name = "${var.vm_name}"
    sources = [
        "sources.proxmox-iso.ubuntu-server-24-04"
    ]

    provisioner "file" {
        source = "files/105-pve.cfg"
        destination = "/tmp/105-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/105-pve.cfg /etc/cloud/cloud.cfg.d/105-pve.cfg" ]
    }

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template with Docker Installation and other packages #4
    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get -y update",
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
            "sudo apt-get install -y btop curl docker-compose gdu htop neofetch python3-pip"
        ]
    }
}
