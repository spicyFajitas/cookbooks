## this is the example we worked on in class in SAT 4411

provider "vsphere" {
  user                 = "root"
  password             = "P@ssw0rd"
}

data "vsphere_datacenter" "datacenter" {
  name = "dc-r2"
}

data "vsphere_datastore" "datastore" {
  name          = "ds0"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "cluster-01"
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "ubuntu"
  resource_pool_id = "res-36"
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 1
  memory           = 1024
  guest_id         = "other3xLinux64Guest"
  network_interface {
    network_id   = ""
    ipv4_address = "192.168.1.45"
    ipv4_netmask = 24
    ipv4_gateway = "192.168.1.1"
      }
  disk {
    label = "disk1"
    size  = 20
  }
  cdrom {
    datastore_id = data.vsphere_datastore.iso_datastore.id
    path         = "/Volume/Storage/ISO/ubuntu.iso"
  }
}