# Lab9

## Firewall Rules Implemented and Dropped Traffic Being Logged on Prod-Joomla

Ran commands on `Prod-Joomla`:

```bash
sudo su
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -j LOG
```

## Correct Rules Implemented on Network Firewall

To configure the pfSense rules, log into the Security-Desk computer and navigate to pfSense(172.16.20.250). Navigate to Firewall > Rules > WAN and create three rules:

- Allow IPv4 from any source to destination 172.16.10.100 port 443 "Allow HTTPS to Joomla".
- Allow IPv4 from any source to destination 172.16.10.100 port 80 "Allow HTTP to Joomla".
- Block Any IPv4+6 source to any destination on any protocol.

## Firewall Rules Implemented and Dropped Traffic Being Logged on Database

On the Database server, open Windows Firewall with Advanced Security

On the overview page, Click "Windows Firewall Properties". For each profile Domain, Private, and Public, Customize the Logging settings and change the path to `C:\Windows\System32\LogFiles\Firewall\pfirewall.log`. Also set "Log dropped packets" to `yes`

Create an inbound firewall rule called MSP Ports that allows TCP ports 135, 137, 445, 5985. MySQL and SMB already have rules that enable those ports.

## Firewall Rules Implemented and Dropped Traffic Being Logged on Workstation

On the Workstation-Desk, open Windows Firewall with Advanced Security

On the overview page, Click "Windows Firewall Properties". For each profile Domain, Private, and Public, Customize the Logging settings and change the path to `C:\Windows\System32\LogFiles\Firewall\pfirewall.log`. Also set "Log dropped packets" to `yes`

Create an inbound firewall rule called MSP Ports that allows TCP ports 137, 445, 5985.

## Firewall Rules Implemented and Dropped Traffic Being Logged on Domain Controller

On the Domain-Controller, open Windows Firewall with Advanced Security

On the overview page, Click "Windows Firewall Properties". For each profile Domain, Private, and Public, Customize the Logging settings and change the path to `C:\Windows\System32\LogFiles\Firewall\pfirewall.log`. Also set "Log dropped packets" to `yes`

Create an inbound firewall rule called MSP Ports that allows TCP ports 88, 135, 389, 445, 636, 3268, 3269, and 49152.

## Firewall Rules Implemented and Dropped Traffic Being Logged on Fileshare

Ran commands on `Fileshare`:

```bash
sudo su
iptables -A INPUT -p tcp --dport 137 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 445 -j ACCEPT
iptables -A INPUT -j LOG
```
