# Fail2Ban

```shell
fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g'
sshd
root@docker-host:~# fail2ban-client set sshd unbanip <ip>
```
