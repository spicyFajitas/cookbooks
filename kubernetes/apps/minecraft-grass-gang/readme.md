# minecraft-gg

Grass Gang's Paper 1.21.10 server, `gg.spicyfajitas.com` via mc-router.
Replaces the `minecraft-grass-gang` VM (10.100.10.29) and
`ansible/roles/minecraft-grass-gang`.

Migrated 2026-11-08: `/opt/minecraft/grass-gang` was rsynced into the PVC
as-is, **except `bluemap/`** (~30G of rendered tiles). BlueMap will
re-render from scratch if it's enabled and has a webserver to serve from;
nothing exposes its web UI yet.

Not carried over: the VM's `minecraft-discord-webhook` systemd service
(it watched for an old jar name, `paper-1.21.5-114.jar`, so it had
already stopped firing after the 1.21.10 upgrade). The in-server
BasicDiscordRelay plugin still runs.
