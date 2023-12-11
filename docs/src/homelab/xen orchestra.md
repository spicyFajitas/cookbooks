# XCP-NG

## Overview

Information regarding XCP-NG hypervisor.

## Xen Orchestra

This section covers basics of Xen Orchestra, the web management interface for XCP-NG. 

### Installation

This is a process to follow to install Xen Orchestra Community Edition (xo-ce) on an existing XCP-NG installation. You need to be on a local or SSH shell session.

```bash
# install git
yum install git vim

# clone Xen Orchestar Installer Updater Tool
git clone https://github.com/ronivay/XenOrchestraInstallerUpdater.git

cd XenOrchestraInstallerUpdater/

cp sample.xo-install.cfg xo-install.cfg

# read through configuration file in case you want to make changes
vim xo-install.cfg

# this throws an error - it would like you to import a VM for Xen Orchestra instead of installing one
./xo-install.sh

# by default, imports a debian VM for xo-ce with 2 vCPUs, 4 GiB RAM, 10 GiB disk
./xo-vm-import.sh

# since we don't need 2 vCPUs and 4 GiB of memory, we'll change the resource usage to be smaller
xe vm-shutdown vm=xo-ce
xe vm-param-set VCPUs-at-startup=1 uuid=`vm uuid`
xe vm-param-set VCPUs-max='1' uuid=`vm uuid`
xe vm-memory-limits-set vm=xo-ce static-min=512MiB dynamic-min=512MiB dynamic-max=512MiB static-max=512MiB
xe vm-start vm=xo-ce
```

### Updates

In order to install, we follow a similar process by SSH'ing into the XCP-ng server.

```bash
cd XenOrchestraInstallerUpdater/

git pull

./xo-install.sh --Update
```
