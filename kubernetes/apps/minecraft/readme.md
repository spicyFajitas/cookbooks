# minecraft

k3s replacement for `ansible/roles/minecraft` (Paper server on
its own VM, `minecraft` / 10.100.10.29). Runs
`itzg/minecraft-server` with the same Paper build, heap, JVM flags,
whitelist and plugin configs the role managed.

## What's here

- `01-pvc.yaml`: the whole server directory (world, plugins, configs).
- `02-deployment.yaml`: the server. Ships with **`replicas: 0`** until the
  world data is copied over (see below).
- `03-service.yaml`: Paper's Service, **ClusterIP only**. Paper runs in
  offline mode behind Velocity, so it must not be reachable directly.
- `04-velocity.yaml` + `config/velocity.toml`: Velocity proxy, the public
  entry point. `LoadBalancer` via k3s ServiceLB, so `25565` is bound on the
  k3s node (10.100.10.12). Does the Mojang auth and forwards player
  identity to Paper (modern forwarding, signed with
  `velocity-forwarding.sops.yaml`; the `velocity-forwarding` init
  container in `02-deployment.yaml` writes the same secret into Paper's
  `paper-global.yml`).
- `05-limbo.yaml`: NanoLimbo holding server. When Paper restarts, Velocity
  moves players here (an empty void) instead of disconnecting them. Back to
  the real server with `/server paper` once it's up. Needs Velocity
  forwarding too (Velocity refuses backends without it); its settings are
  `config/nanolimbo-settings.yml`, secret filled in by an init container.
- `06-public-dns.yaml`: DDNS updater keeping `minecraft.spicyfajitas.com`
  pointed at the home WAN IP (DNS-only, not proxied). Runs in the
  `external-dns` namespace to reuse its Cloudflare token.
- `config/axgraves-config.yml`: copied verbatim from the role's
  `axgrave-config.yaml.j2` (it had no templating). Kustomize turns it into
  a ConfigMap, and an initContainer copies it into `plugins/AxGraves/` on
  every start.
- `discord-relay-config.sops.yaml`: the DiscordRelay
  `config.yml`. It's committed with **placeholder** values, so fill it in
  with the real values from `ansible/roles/minecraft/vaults/production.yml`:

  ```bash
  ansible-vault view ansible/roles/minecraft/vaults/production.yml   # discord_bot_token, discord_channel_id
  sops kubernetes/apps/minecraft/discord-relay-config.sops.yaml
  ```

  Not in `kustomization.yaml`, same as every other SopsSecret here. Apply it
  by hand (step 2 below). Until it exists, the initContainer leaves
  whatever DiscordRelay config came over with the world data alone.

## Adding Velocity (one-time)

Apply the forwarding secret **before** syncing the app. Paper's init
container needs it and the pod won't start without it:

```bash
kubectl apply -f kubernetes/apps/minecraft/velocity-forwarding.sops.yaml
```

Then sync. Paper restarts once with forwarding on; Velocity takes over the
node's 25565 from Paper's old LoadBalancer.

## Not carried over

- `fail2ban`: there's no SSH into a pod, and the enforced whitelist is the
  access control for the game port.
- The SMB backup mount and the Discord webhook script/service were already
  commented out in the role.
- The tmux console. Use `rcon-cli` instead (below).

## Cutover (after merge)

Argo CD's `apps` ApplicationSet picks up this directory automatically.
With `replicas: 0` that creates the namespace, PVC, Service and ConfigMap,
but no server.

1. **Stop the VM's server** so the world isn't changing mid-copy:
   `ssh adam@10.100.10.29 sudo systemctl stop minecraft`
2. **Apply the Discord secret** (once you've filled it in):
   `kubectl apply -f kubernetes/apps/minecraft/discord-relay-config.sops.yaml`
3. **Copy the data onto the PVC.** local-path won't bind the PVC until a
   pod uses it, so use a throwaway pod:

   ```bash
   export KUBECONFIG=~/.kube/k3s-homelab.yaml
   kubectl -n minecraft run restore --restart=Never --image=busybox:1.36 \
     --overrides='{"spec":{"containers":[{"name":"restore","image":"busybox:1.36","command":["sleep","infinity"],"volumeMounts":[{"name":"d","mountPath":"/data"}]}],"volumes":[{"name":"d","persistentVolumeClaim":{"claimName":"minecraft-data"}}]}}'
   kubectl -n minecraft wait pod/restore --for=condition=Ready
   ssh adam@10.100.10.29 'tar -C /opt/minecraft/grass-gang -czf - .' \
     | kubectl -n minecraft exec -i restore -- tar -C /data -xzf -
   kubectl -n minecraft exec restore -- chown -R 1000:1000 /data
   kubectl -n minecraft delete pod restore
   ```

   The old `paper-*.jar` and `start.sh` come along harmlessly. The image
   downloads its own Paper jar.
4. **Start the server:** change `replicas: 0` to `1` in
   `02-deployment.yaml` and merge.
5. **Move the router's port forward** for `25565` from 10.100.10.29 to
   10.100.10.12.
6. Once players have confirmed the world is intact, drop the
   `minecraft_grass_gang` play from `ansible/site.yml` and shut the VM down.

## Day to day

```bash
kubectl -n minecraft exec -it deploy/minecraft -- rcon-cli   # console
kubectl -n minecraft logs -f deploy/minecraft
```

Connect to `minecraft.spicyfajitas.com` (port 25565, the default).

Restarting Paper (config change, upgrade) parks players in limbo instead
of kicking them; they type `/server paper` once it's back. Restarting
Velocity *does* disconnect everyone, so only touch `velocity.toml` /
`04-velocity.yaml` when you mean to.

Whitelist: edit `WHITELIST` in `02-deployment.yaml`. `whitelist.json` is
rebuilt from it on every start. Paper upgrades: bump `VERSION`; the
newest stable Paper build for it is picked up on each start. `VERSION`
only ever goes **up**: a world that has run on a version can't be opened
on an older one. Check every plugin has a build for the new version first
(Gunshell is usually the one holding things back).

Plugins: the ones on Modrinth are listed in `MODRINTH_PROJECTS` in
`02-deployment.yaml` and updated to their newest release for `VERSION` on
each start -- add/remove a line to add/remove a plugin. The rest
(BasicDiscordRelay, SleepMost, Timber) are hand-placed jars in
`/data/plugins` that came over from the VM; replace them by `kubectl cp`.

Gunshell's resource pack isn't set: its newest release targets 1.20.4 and
custom item models changed in 1.21.4, so guns show as their base vanilla
items. If an updated pack appears, set `RESOURCE_PACK` /
`RESOURCE_PACK_SHA1` on the Paper container.
