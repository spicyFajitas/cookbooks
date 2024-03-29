# Proxmox

## Known Issues

### Attached Devices Changing Device Number

I had added a PCIe 4 port gigabit network adapter to my primary Proxmox host because I didn't want to store it loosely in my tech tote. I removed it as I have plans to add a PCIe bifurcation card to run disks in mirrored mode and improve VM performance. However, Proxmox networking was screwed up because `/etc/network/interfaces` changed with the device rename of the primary ethernet adapter I was using (the one attached to the motherboard).

The fix is running `journalctl -b 0 | grep renamed` - this will show you the old name of the network adapter and what it was changed to. You just need to edit `/etc/network/interfaces` and revert the automatic name change if removing devices.

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

To remove the popup message “You do not have a valid subscription for this server”, follow the instructions below or on [this GitHub repo](https://github.com/foundObjects/pve-nag-buster/). This is also known as the pve-nag-buster.

Installation with wget

```bash
wget https://raw.githubusercontent.com/foundObjects/pve-nag-buster/master/install.sh

# Always read scripts downloaded from the internet before running them with sudo
sudo bash install.sh

# or ..
chmod +x install.sh && sudo ./install.sh
```

Installation with git

```bash
git clone https://github.com/foundObjects/pve-nag-buster.git

# Always read scripts downloaded from the internet before running them with sudo
cd pve-nag-buster && sudo ./install.sh
```

Uninstall

```
sudo ./install.sh --uninstall
# remove /etc/apt/sources.list.d/pve-no-subscription.list if desired

```

### Storage

#### Local Storage

Navigate via the GUI to Server > Disks > `/disk/name` for whatever option you want to configure with local disks.

If a local disk fails, you need to remove it by navigating to the disk type, destroying the disk. Navigate to the Disks menu and `Initialize Disk with GPT`. Then, you can navigate to the storage type and create the storage type you want.

For example, when `storageSSD` failed, I had to delete the disk in the `LVM-Thin` menu, Re-Initialize the Disk with GPT, then navigate to LVM-Thin and `Create: Thinpool` on the unused disk - `/dev/sda`.

##### SMART

SMART is usually enabled by default but if it is not, `smartctl -a /dev/sdX` Turn on SMART if not enabled

#### Networked Storage

Datacenter -> Storage -> Add ->  {{ storage type }}

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

!!! note
    This documentation is based on the ["Example with EFI" docs](https://pve.proxmox.com/wiki/Resize_disks#Online_for_Linux_Guests)

Note: ubuntu says virtual machine disks are `vda` devices. My ubuntu docker VM had vda1 and vda2, with vda2 being the data partition.

```bash
# list system messages about disk size changing
dmesg | grep vda

# list disks in fdisk
fdisk -l /dev/vda | grep ^/dev

# enter the partitioning tool
parted /dev/vda

# print partitions in parted
(parted) print

# resize specific partition with percentage of free space
# NOTE: be sure to check the partition number on the host. On my docker host,
# it just so happens to be partition 2.
(parted) resizepart 2 100%

# view new partition sizes
(parted) print

# resize file system to fill disk space
resize2fs /dev/vda2
```

## Email Alerts

This section is based on YouTuber Techno Tim's guide [Set up alerts in Proxmox before it's too late!](https://technotim.live/posts/proxmox-alerts/)

### TLDR: Alert Config

???+ note "Required Config"

    You'll need a Google app password for the Google account you want to use to send emails. Follow [Google's guide](https://support.google.com/accounts/answer/185833?hl=en) on how to make [app passwords](https://myaccount.google.com/apppasswords).

    ```bash
    # commands to be run in proxmox shell
    apt update
    apt install -y libsasl2-modules mailutils

    # configure postfix
    echo "smtp.gmail.com your-email@gmail.com:YourAppPassword" > /etc/postfix/sasl_passwd
    # update permissions
    chmod 600 /etc/postfix/sasl_passwd
    # hash the file
    postmap hash:/etc/postfix/sasl_passwd
    # ensure hashed db file was created 
    cat /etc/postfix/sasl_passwd.db
    ```
    
    Edit postfix config `vim /etc/postfix/main.cf`

    ```conf
    # /etc/postfix/main.cf
    # google mail configuration
    relayhost = smtp.gmail.com:587
    smtp_use_tls = yes
    smtp_sasl_auth_enable = yes
    smtp_sasl_security_options =
    smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
    smtp_tls_CAfile = /etc/ssl/certs/Entrust_Root_Certification_Authority.pem
    smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache
    smtp_tls_session_cache_timeout = 3600s
    ```

    ```bash
    # reload post fix
    systemctl postfix reload

    echo "This is a test message sent from postfix on my Proxmox Server" | mail -s "Test Email from Proxmox" your-email@gmail.com
    ```

???+ note "Optional Config"

    ```bash
    apt update
    apt install postfix-pcre

    vim /etc/postfix/smtp_header_checks
    ```

    Add the following text:

    ```conf
    # /etc/postfix/smtp_header_checks
    /^From:.*/ REPLACE From: pve1-alert <pve1-alert@something.com>
    ```

    ```bash
    # hash the file
    postmap hash:/etc/postfix/smtp_header_checks
    # check the contents of the file
    cat /etc/postfix/smtp_header_checks.db
    ```

    Edit postfix config again `vim /etc/postfix/main.cf`:

    ```conf
    smtp_header_checks = pcre:/etc/postfix/smtp_header_checks
    ```

    Reload postfix `systemctl postfix reload`

### Alert Config Explained

Setting up alerts depends on `mailutils`, `libsasl2-modules`, and `postfix-pcre`. According to [their website](https://mailutils.org/), `mailutils` is "Mailutils is a swiss army knife of electronic mail handling. It offers a rich set of utilities and daemons for processing e-mail." `libsasl2-modules` provides authentication with Google's servers using the app password, and `postfix-pcre` allows Perl Compatible Regular Expression for modifying the headers of the emails that are sent. Basically, you're setting up the email server config to reach out to Google's mail servers and authenticate using the app password.
