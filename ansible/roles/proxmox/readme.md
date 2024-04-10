# Proxmox

## Overview

You'll need to manually run a command to re-hash the database fies on the server after changing either `cookbooks/ansible/roles/proxmox/templates/sasl_passwd.j2` or the SMTP header of the `Configure SMTP header checks` task in `cookbooks/ansible/roles/proxmox/tasks/main.yml`:

```bash
# for /etc/postfix/sasl_passwd
postmap hash:/etc/postfix/sasl_passwd

# for /etc/postfix/smtp_header_checks
postmap hash:/etc/postfix/smtp_header_checks
```

## Known Issues

The [](../fortune/tasks/main.yml) `Configure SMTP header checks` task uses the ansible `lineinfile` module instead of the `template` module, so if changes are made they are appended to `/etc/postfix/smtp_header_checks` instead of overwriting the existing changes.

##  Dependencies

- helper/ssh
- helper/packages
- helper/timezone
