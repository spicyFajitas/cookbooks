# minecraft

Fresh Paper 26.3 server on `itzg/minecraft-server`, reached at
`minecraft.spicyfajitas.com` through mc-router
(`kubernetes/apps/mc-router/`).

The other two servers on the cluster are their own apps:
`kubernetes/apps/minecraft-grass-gang` (Grass Gang, moved from the
`minecraft-grass-gang` VM) and `kubernetes/apps/minecraft-masonadam`
(Mason & Adam, moved from the `minecraft` VM).

## Bedrock / Xbox

Geyser + Floodgate let Bedrock players (Xbox, phone, Windows Bedrock)
join this server only, on UDP 19132 at the same hostname. That port
skips mc-router, so this server is excluded from scale-to-zero (the
`autoScaleDown: "false"` annotation in `03-service.yaml`) and stays up.

- Router: forward **UDP 19132** to 10.100.10.12 (ServiceLB, see
  `04-bedrock-service.yaml`), next to the existing TCP 25565 forward.
- Whitelist: Bedrock players have their own UUIDs, so they're added from
  the console with `/fwhitelist add <gamertag>` (floodgate), not via the
  `WHITELIST` env. `EXISTING_WHITELIST_FILE: MERGE` keeps them.
- Consoles can't type in a server address. MCXboxBroadcast (Geyser
  extension, installed by the init container) signs in as an Xbox
  account and shows the server in its friends' **Friends -> Joinable**
  list. First start logs a microsoft.com/link device code -- sign in
  with an **alt** Xbox account (the project warns accounts can be
  banned). The session is cached under
  `plugins/Geyser-Spigot/extensions/mcxboxbroadcast/` on the PVC. Players
  add that account as a friend; it friends them back automatically.

`06-public-dns.yaml` is the DDNS updater for **all** Minecraft hostnames,
not just this server's -- it lives here for history, see mc-router's
readme for the full hostname list.
