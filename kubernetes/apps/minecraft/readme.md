# minecraft

Fresh Paper 26.3 server on `itzg/minecraft-server`, reached at
`minecraft.spicyfajitas.com` through mc-router
(`kubernetes/apps/mc-router/`).

The other two servers on the cluster are their own apps:
`kubernetes/apps/minecraft-gg` (Grass Gang, moved from the
`minecraft-grass-gang` VM) and `kubernetes/apps/minecraft-masonadam`
(Mason & Adam, moved from the `minecraft` VM).

`06-public-dns.yaml` is the DDNS updater for **all** Minecraft hostnames,
not just this server's -- it lives here for history, see mc-router's
readme for the full hostname list.
