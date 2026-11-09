# minecraft-masonadam

Mason & Adam's Paper 1.21.5 server, `masonadam.spicyfajitas.com` via
mc-router. Replaces the `minecraft` VM (10.100.10.28) and
`ansible/roles/minecraft-baremetal`.

Migrated 2026-11-08: `/opt/minecraft/mason-adam-paper-1.21.5` was rsynced
into the PVC as-is, including the old Spigot BuildTools leftovers and the
3G `backup/` dir -- safe to prune later.

Bedrock dropped: `Geyser-Spigot.jar` and `floodgate-spigot.jar` were
renamed to `*.jar.disabled` in `plugins/` (mc-router can't route UDP).
