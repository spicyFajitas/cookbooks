# Lab8

All documentation is written in markdown format

## Joomla Accounts That Do Need a Password Reset Are Marked for One

1. Log into Domain Controller
1. Open Server Manager
1. Open Tools > Active Directory Administrative Center
1. Browse Domain Users
1. Jot down users for later `/home/playerone/Desktop/users.txt` file on Security-Desk computer
1. On Security-Desk launch attack against Joomla server
1. `nmap -sV 172.16.10.100 --script http-joomla-brute --script-args userdb=/home/playerone/Desktop/users.txt,passdb=/usr/share/wordlists/rockyou.txt`
1. Try logins in Joomla website login `http://172.16.10.100/index.php?option=com_users&view=login`
1. Login to Joomla administrative panel `http://172.16.10.100/administration`
1. Select users with pwn'd passwords
1. Batch update > Require Password Reset = Yes

## Users

These are the users in the `users.txt` file

```txt
asteele
fileshare
Guest
jsmith
jraffin
jcortes
krbtgt
manderson
nkeefe
playerone
rcortes
sec-desk
skeefe
sshd
sshd_server
tclark
```

## AD Accounts That Do Need a Password Reset Are Marked for One

1. On Security-Desk, launch attack against Domain Controller with SMB connections
1. `hydra -L /home/playerone/Desktop/users.txt -P /usr/share/wordlists/rockyou.txt 172.16.30.55 smb`
1. Mark bad accounts in AD
1. Active Directory Users and Computers > Right Click Properties > Check User must change password at next login
