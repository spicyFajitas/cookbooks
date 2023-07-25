# Packer

## Overview

In the packer directory a credentials file needs to be created: `credentials.pkr.hcl`

Contents of file:
```
proxmox_api_url = "{{ https://url-to-instance:port }}"  # Your Proxmox IP Address
proxmox_api_token_id = "{{ token id }}"  # API Token ID
proxmox_api_token_secret = "{{ API secret }}"
```

In order to run the packer build, in the folder first issue the command `packer init`. Then, you can run the packer build with `packer build -var-file=credentials.pkr.hcl ubuntu-server-focal-docker.pkr.hcl`
