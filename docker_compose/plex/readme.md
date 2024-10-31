# Plex

```shell
root@fedora:/opt/media# cat /etc/cron.d/update-plex 
# min hour DoM month DoW
30 3 * * 0 root /opt/media/update-plex.sh

# min hour DoM month DoW
0 4 * * 0 root /opt/media/backup-plex.sh

```