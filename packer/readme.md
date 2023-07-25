# Packer

## Overview

In the packer directory a credentials file needs to be created: `credentials.pkr.hcl`

Contents of file:

```
proxmox_api_url = "https://0.0.0.0:8006/api2/json"  # Your Proxmox IP Address
proxmox_api_token_id = "api_token"  # API Token ID
proxmox_api_token_secret = "your-api-token-secret"
```

In order to run the packer build, in the folder first issue the command `packer init`. Then, you can run the packer build with `packer build -var-file=credentials.pkr.hcl ubuntu-server-focal-docker.pkr.hcl`
