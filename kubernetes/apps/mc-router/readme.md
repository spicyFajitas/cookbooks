# mc-router

[itzg/mc-router](https://github.com/itzg/mc-router) in front of every
Minecraft Java server on the cluster: one LoadBalancer on `:25565`
(the node, 10.100.10.12, router port-forwards to it), routing by the
hostname the player connected with.

| Hostname                     | Server                                        |
| ---------------------------- | --------------------------------------------- |
| `minecraft.spicyfajitas.com` | `kubernetes/apps/minecraft` (Paper 26.3) -- also the default for unmatched hostnames / raw IP |
| `gg.spicyfajitas.com`        | `kubernetes/apps/minecraft-gg` (Grass Gang, Paper 1.21.10) |
| `masonadam.spicyfajitas.com` | `kubernetes/apps/minecraft-masonadam` (Mason & Adam, Paper 1.21.5) |

Public DNS for all three is the DDNS updater in
`kubernetes/apps/minecraft/06-public-dns.yaml` (one A record per name to
the WAN IP, DNS-only).

Java only. Bedrock (UDP) can't be routed by hostname, which is why
mason-adam's Geyser/floodgate were disabled in the move.

Backends see mc-router's pod IP as every player's address (no PROXY
protocol configured), so IP bans in a server's `banned-ips.json` won't
match real players -- ban by name/UUID instead.
