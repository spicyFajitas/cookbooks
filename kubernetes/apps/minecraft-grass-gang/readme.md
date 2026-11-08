# minecraft-grass-gang

k3s replacement for `ansible/roles/minecraft-grass-gang` (Paper server on
its own VM, `minecraft-grass-gang` / 10.100.10.29). Runs
`itzg/minecraft-server` with the same Paper build, heap, JVM flags,
whitelist and plugin configs the role managed.

## What's here

- `01-pvc.yaml`: the whole server directory (world, plugins, configs).
- `02-deployment.yaml`: the server. Ships with **`replicas: 0`** until the
  world data is copied over (see below).
- `03-service.yaml`: `LoadBalancer` via k3s ServiceLB, so `25565` is bound
  on the k3s node (10.100.10.12).
- `config/axgraves-config.yml`: copied verbatim from the role's
  `axgrave-config.yaml.j2` (it had no templating). Kustomize turns it into
  a ConfigMap, and an initContainer copies it into `plugins/AxGraves/` on
  every start.
- `secrets/discord-relay-config.sops.yaml`: the DiscordRelay
  `config.yml`. It's committed with **placeholder** values, so fill it in
  with the real values from `ansible/roles/minecraft-grass-gang/vaults/production.yml`:

  ```bash
  ansible-vault view ansible/roles/minecraft-grass-gang/vaults/production.yml   # discord_bot_token, discord_channel_id
  sops kubernetes/apps/minecraft-grass-gang/secrets/discord-relay-config.sops.yaml
  ```

  Not in `kustomization.yaml`, same as every other SopsSecret here. Apply it
  by hand (step 2 below). Until it exists, the initContainer leaves
  whatever DiscordRelay config came over with the world data alone.

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
   `kubectl apply -f kubernetes/apps/minecraft-grass-gang/secrets/discord-relay-config.sops.yaml`
3. **Copy the data onto the PVC.** local-path won't bind the PVC until a
   pod uses it, so use a throwaway pod:

   ```bash
   export KUBECONFIG=~/.kube/k3s-homelab.yaml
   kubectl -n minecraft-grass-gang run restore --restart=Never --image=busybox:1.36 \
     --overrides='{"spec":{"containers":[{"name":"restore","image":"busybox:1.36","command":["sleep","infinity"],"volumeMounts":[{"name":"d","mountPath":"/data"}]}],"volumes":[{"name":"d","persistentVolumeClaim":{"claimName":"minecraft-data"}}]}}'
   kubectl -n minecraft-grass-gang wait pod/restore --for=condition=Ready
   ssh adam@10.100.10.29 'tar -C /opt/minecraft/grass-gang -czf - .' \
     | kubectl -n minecraft-grass-gang exec -i restore -- tar -C /data -xzf -
   kubectl -n minecraft-grass-gang exec restore -- chown -R 1000:1000 /data
   kubectl -n minecraft-grass-gang delete pod restore
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
kubectl -n minecraft-grass-gang exec -it deploy/minecraft -- rcon-cli   # console
kubectl -n minecraft-grass-gang logs -f deploy/minecraft
```

Whitelist: edit `WHITELIST` in `02-deployment.yaml`. `whitelist.json` is
rebuilt from it on every start. Paper upgrades: bump `VERSION` /
`PAPER_BUILD`.
