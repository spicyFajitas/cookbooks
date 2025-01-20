# Packer

## Overview

In the packer directory a credentials file needs to be created: `credentials.pkr.hcl`. The data for this can also be found in [the terraform credentials file](../terraform/proxmox/credentials.auto.tfvars)

Contents of file:

```hcl
proxmox_api_url = "https://0.0.0.0:8006/api2/json"  # Your Proxmox IP Address
proxmox_api_token_id = "api_token"  # API Token ID
proxmox_api_token_secret = "your-api-token-secret"
```

In order to run the packer build, in the folder first issue the command `packer init`. Then, you can run the packer build with `packer build -var-file=credentials.pkr.hcl ubuntu-server-focal-docker.pkr.hcl`

## HTTP Folder

Look over the contents of the `http` folder to ensure everything is Kosher:tm:.

## Issues

I ran into an issue where packer would be sitting at `Waiting for SSH to become available...` - this is because I did not edit the `user-data` file in the [http folder](./http/user-data)

## Updating ISOs

Currently, I manually download the ISOs to Proxmox and then direct packer to look for a local ISO file to build from. This could be switched to downloading the ISO during the packer run but that would take longer

### Variables to Update

- `source/vm_name`
- `source/template_description`
- `source/iso_file`
- `build/name`
- `build/sources`

## Resources

- <https://github.com/justin-p/packer-proxmox-ubuntu2004?tab=readme-ov-file>
- <https://github.com/MGertz/packer-proxmox/blob/main/http/user-data>
- <https://github.com/jacaudi/packer-template-debian-11/blob/main/http/cloud.cfghttps://github.com/jacaudi/packer-template-debian-11/blob/main/http/cloud.cfg>
- <https://dev.to/aaronktberry/creating-proxmox-templates-with-packer-1b35>
- <https://github.com/romantomjak/packer-proxmox-template>
- <https://medium.com/@saderi/create-vm-templates-on-proxmox-with-packer-84723b7e3919>
- <https://ronamosa.io/docs/engineer/LAB/proxmox-packer-vm/#httpuser-data>
- <https://github.com/hashicorp/packer-plugin-proxmox/issues/87>
- <https://stackoverflow.com/questions/72567455/running-cloud-init-twice-via-packer-terraform-on-vmware-ubuntu-22-04-guest>
- <https://gitlab.com/kilo40/Packer_templates>
