# Proxmox

## Setup Tasks

Most of these are based on YouTuber Techno Tim's video [Before I do anything on Proxmox, I do this first...](https://www.youtube.com/watch?v=GoZaMgEgrHw) but there are some configurations I do outside of the video as well.

### Configure Updates

Edit `/etc/apt/sources.list`

Add line for non-production use `deb http://download.proxmox.com/debian buster pve-no-subscription`

Edit enterprise list

Comment out line in `etc/apt/sources.list.d/pve-enterprise.list` if this is not being used in company enterprise environment.

`apt-get update`

`apt-get upgrade`

`apt dist-upgrade`

Reboot

### Turn off No-Subscription Notice

To remove the popup message “You do not have a valid subscription for this server”, follow the instructions on [this GitHub repo](https://github.com/foundObjects/pve-nag-buster/). This is also known as the pve-nag-buster.

### Storage

#### Local Storage

Navigate via the GUI to Disks > `option` for whatever option you want to configure with local disks.

##### SMART

SMART is usually enabled by default but if it is not, `smartctl -a /dev/sdX` Turn on SMART if not enabled

#### Networked Storage

Dataventer -> Storage -> Add ->  {{ storage type }}

Configure SMB with the following settings:

```comment
ID: spicyNAS-proxmox
Server: 10.100.10.15 (or IP of TrueNAS instance)
Username: proxmox
Password: bitwarden {{ TrueNAS Samba Habanero SMB }}
Share: proxmox
Nodes: All
Enable: Checked
Content: (Select all)
```

### Schedule Backups

=== "General"

    The scheduling supports cron format in the "schedule" field.
    Datacenter -> Backups -> Add

    ```markdown
    Node: (pick node/nodes)
    Storage: nas device
    Schedule: 03:00 (3 AM every morning)
    Selection Mode: all
    Send email to: enter email
    Email: notify always
    Compression: ZTSD
    Mode: Snapshot (this has always worked for me)
    Enable: [x] 
    ```

=== "Retention"

    ```markdown
    Keep all backups: [ ] unchecked
    Keep Last: 8

    OR

    Keep Hourly: 0
    Keep Daily: 5
    Keep Weekly: 2
    Keep Monthly: 2
    Keep Yearly: 0
    ```

### Schedule Snapshots

Don't know where this is yet but it'd be neat to implement scheduled snapshots as well as backups.

### PCI Passthrough / IOMMU

Prerequisites: Motherboard, CPU, and BIOS all need to support. Search the internet and updated docs if/when you need PCI passthrough.

### VLAN Aware

PVE Node -> Network -> Select Network Adapter (bridge) -> Enable VLAN Aware

You will probably want to set VLAN on the network adapter next.

### Windows VirtIO Drivers

Yeah I'll get to this some day. For now the smaller resolution box doesn't bother me enough yet.

## Cloud Init Ubuntu Template

In order to save time, we'll create a template for our Ubuntu servers.

First, create a VM with the following specific options:

* OS: do not use any media
* System: Qemu Agent checked
* Disks: Delete default disk
* CPU: can be low, change later
* Memory: can be low, chamge later
Other options can be set as desired.

Next, enter the Proxmox shell.

```bash
# Download ubuntu cloud image
wget https://cloud-images.ubuntu.com/<path to specific cloud image>

# Set up console for viewing VM output
qm set 900 --serial0 socket --vga serial0

# Change disk type to .qcow2 in order to increase size
mv ubuntu-22.04-minimal-cloudimg-amd64.img ubuntu-22.04-minimal-cloudimg-amd64.qcow2

# Increase size
qemu-img resize ubuntu-22.04-minimal-cloudimg-amd64.qcow2 32G

# Import disk into VM
# Note: 900 is VM ID, local-lvm is storage for VM images
qm importdisk 900 ubuntu-22.04-minimal-cloudimg-amd64.qcow2 local-lvm

```

Once done in the shell, go to VM options > Boot order. Enable new disk, and move to 2nd priority.

If needed, install the `qemu-guest-agent` package on the machine.

Be sure when deploying from clones to change the IP address in Cloud Init options to static.

## Common Tasks

### Growing Disks (VMs)

!!! warning
    This documentation is wrong!!! Follow these docs instead: https://pve.proxmox.com/wiki/Resize_disks

Note: ubuntu says virtual machine disks are `vda` devices. My ubuntu docker VM had vda1 and vda2, with vda2 being the data partition.

Grow partition

```bash
# lisk block devices and search for new disk
sudo lsblk -d | grep disk 

# unmount partition, might get an error
sudo umount /dev/vda2

# open partition software
sudo parted

# select device
select /dev/vda2

# print drive information
# if you've already grown the disk in proxmox, it will prompt you to grow the partition with all of the available free space. Accept the default that it suggests.
print
```

Grow filesystem to match partition

!!! note
    These steps can be scary, but don’t worry, you shouldn’t lose your data as we don’t format the disk content (make sure to have a backup anyway!). All we do is delete the existing partition and create a new larger partition. When it prompts if you'd like to overwrite existing data, say "no".

```bash
# open file disk management software
sudo fdisk /dev/vda

# delete partition
d # if prompted for partition number select 2

# create new partition (accept default options)
n

# check the partition table is as desired
p

# write changes to disk
w

# exit fdisk
exit

# resize filesystem
sudo resize2fs /dev/vda2
```

