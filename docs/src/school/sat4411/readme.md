# SAT 4411 Lab 5 - Terraform and VM Automation

This is the documentation for this lab

Right now the files are in a good state to where you can run the plan and apply commands and they will run without errors. You'll have to create a `terraform.tfvars` file and add in the credentials for the vCenter instance.

```tf
# terraform.tfvars
# set of VM values of variables
vsphere_server     = "172.20.191.56"
vsphere_user       = "username"
vsphere_password   = "password"
```

After running `terraform plan` and `terraform apply`, you'll need to manually go into the vCenter instance and delete the TinyCore-tf VM that is created as you can't run the script again without errors after the VM is created.

## Commands

```
# initialize provider and terraform working folder
terraform init

# plan changes (make sure syntax is right)
terraform plan

# apply changes
terraform apply

# automatically approve changes
terraform apply --auto-approve

# remove vms managed by terraform
terraform destroy
```

## Issues

Guest OS has to be "Other Linux 32 Bit"

Navigate to Storage > Datacenter Name (Group12) > Datastore Name (Group 12 Datastore) and navigate through the datastore files until you find the ISO you uploaded (TinyCore 14). The path should be something like `[Group 12 Datastore] contentlib-6cc2a390-34fd-45f5-85ab-861df4d5a085/34d11765-de2b-4c4d-95c3-7a5ccf1f5506/TinyCore-14.0_a2015ad7-54b9-4c7f-8d14-1b17edf57941.iso`

## Miscellaneous

Adjust count in vm resources to adjust number of VMs created
