packer {
  required_plugins {
    name = {
      version = ">= 1"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = ">= 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

variable "vm_name" {
    type = string
    default = "ubuntu-server-noble"
}

variable "proxmox_api_url" {
    type = string
    default = "replace_me_via_env"
}

variable "proxmox_api_token_id" {
    type = string
    default = "replace_me_via_env"
}

variable "proxmox_api_token_secret" {
    type = string
    default = "replace_me_via_env"
    sensitive = true
}

variable "proxmox_node" {
    type = string
    default = "nauvoo"
}

variable "proxmox_storage_pool" {
    type = string
    default = "fast"
}

variable "ssh_username" {
    type = string
    default = "zibbp"
}

variable "ssh_private_key_file" {
    type = string
    default = "~/.ssh/tycho-packer"
}

variable "vm_description" {
    type = string
    default = "Ubuntu Server - Noble"
}

variable "vm_id" {
    type = string
    default = "9000"
}

variable "vm_iso_file" {
    type = string
    default = "local:iso/ubuntu-24.04-live-server-amd64.iso"
}

source "proxmox-iso" "ubuntu-server-noble" {
    // proxmox settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"

    // (Optional) Skip TLS Verification
    // insecure_skip_tls_verify = true
    node = "${var.proxmox_node}"
    vm_id = "${var.vm_id}"
    vm_name = "${var.vm_name}"
    template_description = "${var.vm_description}"

    // download via url
    // iso_url  = "https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso"
    // iso_checksum = "file:https://releases.ubuntu.com/24.04/SHA256SUMS"
    // iso_download_pve = true
    iso_file = "${var.vm_iso_file}"
    iso_storage_pool = "local"
    task_timeout = "5m" // uploading can be slow

    // additional_iso_files {
    //     cd_files = [
    //         "./http/meta-data",
    //         "./http/user-data"
    //     ]
    //     cd_label = "cidata"
    // }

    unmount_iso = true


    qemu_agent = true

    scsi_controller = "virtio-scsi-single"

    disks {
        disk_size = "50G"
        format = "raw"
        storage_pool = "${var.proxmox_storage_pool}"
        type = "scsi"
        cache_mode = "writeback"
        io_thread = true
    }

    cpu_type = "host"
    cores = "2"
    memory = "2048"
    // https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox/latest/components/builder/iso#network-adapters
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    }

    // cloud-init
    cloud_init = true
    cloud_init_storage_pool = "${var.proxmox_storage_pool}"


    // packer boot commands
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]
    boot = "c"
    boot_wait = "5s"

    // packer autoinstall settings
    http_interface = "eth0"
    http_directory = "http"
    http_port_min = 8802
    http_port_max = 8810

    ssh_username = "${var.ssh_username}"
    ssh_private_key_file = "${var.ssh_private_key_file}"

    // timeout if install takes too long
    ssh_timeout = "20m"
}

build {
    name = "${var.vm_name}"
    sources = [
        "source.proxmox-iso.ubuntu-server-noble"
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
            "sudo sync"
        ]
    }

   provisioner "shell" {
       inline = [
           "sed -i '1d' /home/zibbp/.ssh/authorized_keys"
       ]
   }

    provisioner "ansible" {
        playbook_file = "../../homelab/packer.yml"
        user = "zibbp"
         extra_arguments = [ "--scp-extra-args", "'-O'" ]
    }
}