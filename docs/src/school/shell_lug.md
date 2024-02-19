# Linux Users Group Shell

IT blocks all inbound SSH connections from outside of the 141.219.0.0/16 range so by default you can't ssh into Shell from off-campus.

There's a service on port 8443 to allow wrapping ssh traffic in TLS to bypass this block, so if you're connecting from a *nix client you can use the following options to do the TLS-wrapped-SSH:

Using package `socat`:
```
1. Single-Use Command:
ssh -o ProxyCommand="socat - OPENSSL:shell.lug.mtu.edu:8443,verify=0" shell.lug.mtu.edu

2. Add the following to ~/.ssh/config for a Persistent Config:
Host shell
    ProxyCommand          socat - OPENSSL:shell.lug.mtu.edu:8443,verify=0
    ServerAliveInterval   10
```
Using package `openssl`:
```
1. Single-Use Command:
ssh -o ProxyCommand="openssl s_client -quiet -ign_eof shell.lug.mtu.edu:8443 2>/dev/null" shell.lug.mtu.edu

2. Add the following to ~/.ssh/config for a Persistent Config:
Host shell
    ProxyCommand          openssl s_client -quiet -ign_eof shell.lug.mtu.edu:8443 2>/dev/null
    ServerAliveInterval   10
```
If you do the persistent config via ~/.ssh/config option, you can just type "ssh shell" and it'll apply the setting automatically. You can also add your username and pubkey to the host config for a very quick login. More information about the SSH Host configuration file can be found [here](https://linuxize.com/post/using-the-ssh-config-file/)