# Linux Administration

## Overview

This page is dedicated to helpful commands, techniques, and packages to system administrators.

## Links

[Ubuntu Cloud Images](https://cloud-images.ubuntu.com/jammy/)

## Common Tasks

### Mounting SMB Share

mount -t cifs -o username={{username}},password={{password}},domain={{domain}} //{{server}}/{{share}} //mnt/{{directory}}

### Mounting NFS Share

mount -t nfs 10.10.0.10:/path/to/share /path/to/mount

## File Permissions

Change ownership `chown <username> </path/to/file>`

Change ownership recursively with the `-r` flag `chown -r <username> </path/to/file>`

## Networking

`etc/network/interfaces` will contain information related to the interfaces

DHCP release `dhclient -r`

DHCP renew `dhclient`

DHCP verbose `dhclient -v`

Manually set IP addresses `ip addr add 192.168.1.100/24 dev eth0`

### Netplan Configuration

```yaml
network:
    version: 2
    ethernets:
        eth0:
            addresses:
                - 10.100.10.2/23
            nameservers:
                addresses: [1.1.1.1]
            routes:
                - to: default
                  via: 10.100.10.1
```

## Cron

Cron is a great way to schedule tasks on a linux system. Cron format looks like 

```cron
# minute hour day_of_month month day_of_week
0 6 * * * /path/of/script

# you can also call commands
0 6 * * * uname -r >> /var/log/uname
```

It is good practice to set the time zone in the crontab file so your crons will run at the proper time

```cron
# setting timezone for cron timers
CRON_TZ=America/Detroit
```

## Systemd Timers

Use `systemctl edit service_name.timer` to edit a service or timer with overrides. The `OnCalendar` directive is _additive_ and does not override the existing value. You need to set a blank value before setting the "override" value. 

```shell
[Timer]
OnCalendar=
OnCalendar=Mon *-*-* 03:00:00
```

Reference:

- <https://unix.stackexchange.com/questions/479702/cannot-override-systemd-timer-with-specific-time>
- <https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html#OnActiveSec=>

## Command/Package Mappings and Locations

When looking for the files a command maps to, you can use the `which` command. This shows the location of a command

```bash
# ls -l $(which vi)
-rwxr-xr-x. 1 root root 1180368 Jun 14  2022 /bin/vi
```

You can also look for alternatives if a command might map to two packages

```bash
# ls -l /etc/alternatives/java
lrwxrwxrwx. 1 root root 62 Jul 29 08:51 /etc/alternatives/java -> /usr/lib/jvm/java-11-openjdk-11.0.23.0.9-3.el8.x86_64/bin/java
```

More command/file troubleshooting

```
# rpm -qf /usr/lib/jvm/java-11-openjdk-11.0.23.0.9-3.el8.x86_64/bin/java
java-11-openjdk-headless-11.0.23.0.9-3.el8.x86_64

# alternatives --config java

There are 2 programs which provide 'java'.
  Selection    Command
-----------------------------------------------
*+ 1           java-11-openjdk.x86_64 (/usr/lib/jvm/java-11-openjdk-11.0.23.0.9-3.el9.x86_64/bin/java)
   2           java-1.8.0-openjdk.x86_64 (/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.412.b08-2.el9.x86_64/jre/bin/java)
Enter to keep the current selection[+], or type selection number: 1
# 
```

## Swap

Remove swap `swapoff -a`

Allocate swap `fallocate -l 2G /swapfile`

Set permissions for swap `chmod 600 /swapfile`

Make file usable as swap `mkswap /swapfile`

Activate swap `swapon /swapfile`

Make sure swap is permanent `vim /etc/fstab`  `# /swapfile swap swap defaults 0 0`

Show swap `swapon --show`

Show swap `free -h`

Show swappiness `cat /proc/sys/vm/swappiness`

## Zgrep

Sometimes you need to search the contents of .gz files in your system. Unfortunately, grep doesn’t work on compressed files. To overcome this, people usually advise to first decompress the file(s), and then grep your text, after that finally re-compress your file(s)…

You don’t need to decompress them in the first place. You can use zgrep on compressed or gzipped files.

To search in compressed file, execute the command :

`root@ck [~]#zgrep ‘put-your-text-here’ /your-file-path-here/file.gz`

Example : I want to grep ‘plugged’ in all of my exim_paniclog archived files.

`root@ck [~]# zgrep ‘plugged’ /var/log/exim_paniclog.*`

## Kernel Info

The core component of Linux is the kernel. It is written almost entirely in the C programming language. Kernel version are denoted by major verision, minor version, and revision number.

Ex: typing `uname -r` into a a terminal will give you the following:

```bash
root@ubuntu:~# uname -r
5.15.60-1
```

## Power States

| Command         | Description                                                                                                                                      |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| shutdown –P +4  | Powers off your system in four minute                                                                                                            |
| shutdown –H +4  | Halts the operating system from executing in four minutes, but does not invoke the ACPI function in your BIOS to turn off power to your computer |
| shutdown –r +4  | Reboots your system in four minutes                                                                                                              |
| shutdown –P now | Powers off your system immediately                                                                                                               |
| shutdown –r now | Reboots your system immediately                                                                                                                  |
| shutdown –c     | Cancels a scheduled shutdown                                                                                                                     |
| halt            | Halts your system immediately, but does not power it off                                                                                         |
| poweroff        | Powers off your system immediately                                                                                                               |
| reboot          | Reboots your system immediately                                                                                                                  |

## Shebang

The Shebang specifies the pathname to the shell that is used to interpret the contents of the script.

`#!usr/bin/bash`
`#!usr/bin/python3`

## Boot Process

1. UEFI / BIOS
1. POST
1. MBR/GPT
1. UEFI System Partition
1. Boot Loader
1. /boot/linux-5.4.2 (kernel)
1. Init or Systemd, systemd is more common now
1. Daemons

## Target

Target maps are the newer terminilogy and implementation of runlevels.

1. Poweroff.target - runlevel 0
1. Rescure.target - runlevel 1
1. Multi-user.target - runlevels 2, 3, and 4
1. Graphical.target - runlevel 5
1. Reboot.target - runlevel 6

## Runlevels

Runlevels are the older terminology that correspond to different target maps.

The most common runlevels are 3 and 5 - terminal and GUI, respectively.

0 - Halt
1 - Single User
2 - Multi User
3 - Multi User with Networking
4 - User defined
5 - Multi User with Networking and GUI
6 - Reboot
