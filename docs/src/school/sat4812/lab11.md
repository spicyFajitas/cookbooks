# Lab 11

All documentation is written in markdown format

## Fail2Ban Blocks Suspected Brute Force Traffic

Run commands on `Prod-Joomla` as root:

```bash
# authenticate to superuser
sudo su

# install fail2ban and libapache2-mod-security
dpkg -i fail2ban_0.9.6-2_all.deb libapache2-mod-security2_2.9.1-2_amd64.deb

# fix broken packages
apt update
apt-get install -f

# start fail2ban
systemtl start fail2ban
systemctl status fail2ban

# edit fail2ban to create whitelist rule
vim /etc/fail2ban/jail.d/afulton.conf
```

Contents of `/etc/fail2ban/jail.d/afulton.conf`

```config
[DEFAULT]
ignoreip = 172.31.2.6
```

Run commands on `Prod-Joomla`

```bash
# restart fail2ban
systemctl restart fail2ban
```

## ModSecurity CRS Rules Active

Run the commands on `Prod-Joomla`

```bash
# copy recommended configuration to live configuration
cp owasp-modsecurity/modsecurity.conf-recommended /etc/modecurity/modsecurity.conf

# edit configuration
vim /etc/modsecurity/modsecurity.conf
```

Contents of `/etc/modsecurity/modsecurity.conf`

```config
# comment out DetectionOnly mode and turn on
#SecRuleEngine DetectionOnly
SecRuleEngine On
```

Run commands on `Prod-Joomla`

```bash
# copy crs-setup.conf.example to /etc/modsecurity/crs-setup.conf
cp /home/playerone/owasp-modsecurity-crs-3.2-dev/crs-setup.conf.example /etc/modsecurity/crs-setup.conf

# copy rules from home dir to /etc/
cp -r /home/playerone/owasp-modsecurity-crs-3.2-dev/rules/* /etc/modsecurity/rules/

# edit the config for /etc/apache2/mods-enabled/security2.conf
vim /etc/apache2/mods-enabled/security2.conf
```

```config
# comment out setting:
# IncludeOptional /usr/share/modsecurity-crs/owasp-crs.load

# Load the crs-setup.conf
IncludeOptional /etc/modsecurity/*.conf

# Load the crs rules
Include /etc/modsecurity/rules/*.conf
```

Run commands on `Prod-Joomla`:

```bash
# restart apache2
systemctl restart apache2
```
