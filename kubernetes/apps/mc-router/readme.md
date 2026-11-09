# mc-router

[itzg/mc-router](https://github.com/itzg/mc-router) in front of every
Minecraft Java server on the cluster: one LoadBalancer on `:25565`
(the node, 10.100.10.12, router port-forwards to it), routing by the
hostname the player connected with.

| Hostname                     | Server                                        |
| ---------------------------- | --------------------------------------------- |
| `minecraft.spicyfajitas.com` | `kubernetes/apps/minecraft` (Paper 26.3) -- also the default for unmatched hostnames / raw IP |
| `gg.spicyfajitas.com`        | `kubernetes/apps/minecraft-grass-gang` (Grass Gang, Paper 1.21.10) |
| `masonadam.spicyfajitas.com` | `kubernetes/apps/minecraft-masonadam` (Mason & Adam, Paper 1.21.5) |

Routes come from `mc-router.itzg.me/externalServerName` (and
`defaultServer`) annotations on each server's Service, not a static list.

**Servers sleep when idle.** mc-router scales each server's StatefulSet to
0 after 15 minutes with nobody logged in, and back to 1 when someone logs
in. While asleep, the server list shows the "Sleeping" MOTD. The first
person to join waits for boot (~20-55s); the Java client gives up after
~30s, so they may need to rejoin once. homepage widgets ping the servers
directly and show them offline while asleep. To keep one awake, annotate
its Service `mc-router.itzg.me/autoScaleDown: "false"`.

Public DNS for all three is the DDNS updater in
`kubernetes/apps/minecraft/06-public-dns.yaml` (one A record per name to
the WAN IP, DNS-only).

Java only. Bedrock (UDP) can't be routed by hostname, which is why
mason-adam's Geyser/floodgate were disabled in the move.

Backends see mc-router's pod IP as every player's address (no PROXY
protocol configured), so IP bans in a server's `banned-ips.json` won't
match real players -- ban by name/UUID instead.
