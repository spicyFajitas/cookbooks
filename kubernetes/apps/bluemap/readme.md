# bluemap

Web map viewers for every Minecraft server, served by nginx straight from
each server's PVC (`/data/bluemap/web`, BlueMap's file storage). The
maps stay viewable while the servers sleep (mc-router scales them to 0);
only rendering and live player markers pause.

| Map                                     | Server                                  |
| --------------------------------------- | --------------------------------------- |
| https://map-minecraft.spicyfajitas.com  | `kubernetes/apps/minecraft` (26.3)      |
| https://map-gg.spicyfajitas.com         | `kubernetes/apps/minecraft-grass-gang`  |
| https://map-masonadam.spicyfajitas.com  | `kubernetes/apps/minecraft-masonadam`   |

Reached through the `*.spicyfajitas.com` tunnel wildcard -> Traefik, like
every other web app.

- Rendering is done by the BlueMap plugin inside each server, so maps only
  update while that server is awake.
- Live data (`/maps/*/live/`) is proxied to the server's own BlueMap
  webserver on :8100 via the `bluemap-live` Service; nginx answers 204
  while the server sleeps. Nothing here goes through mc-router, so
  opening a map never wakes a server.
- Each plugin needs `accept-download: true` in
  `plugins/BlueMap/core.conf` on its PVC before it will render.
