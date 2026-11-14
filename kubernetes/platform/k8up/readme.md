# k8up

Nightly backups of PVC data to MinIO AIStor on the TrueNAS box
(`http://10.100.10.15:30320`), using [k8up](https://k8up.io), a restic
operator. The k8s side doesn't need storage built for it: k8up mounts each
PVC in a backup Job and pushes it with restic.

- **What gets backed up:** every PVC in a namespace that has a `Schedule` in
  `01-schedules.yaml`, unless the PVC is annotated `k8up.io/backup: "false"`.
  Each namespace has its own bucket and restic repository, `k8up-<namespace>`.
- **Postgres** (speedtest-tracker) is backed up with `pg_dump` through the
  pod annotation `k8up.io/backupcommand`, not as raw files.
- **Not backed up:** `monitoring` (rebuildable) and the `magic` cache.
- **Manifests and secrets** don't need backing up here. They're in git and
  Argo restores them. Whole-VM backups to the NAS still run nightly in
  Proxmox at 03:00, as the fallback.

Times: backup at 01:30 nightly, prune on Sundays at 04:00 (keeps 7 daily,
4 weekly and 3 monthly), restic check on Sundays at 05:00.

## Setup (once per cluster)

The operator reads the MinIO keys and the restic password from the
`k8up-global` Secret. Like every SopsSecret, it's applied by hand:

```sh
kubectl apply -f kubernetes/platform/k8up/secrets/k8up-global.sops.yaml
```

The MinIO access key needs read/write on `k8up-*` buckets, plus permission
to create them (restic creates each bucket on first run).

## Checking

```sh
kubectl get schedules,backups,snapshots -A
kubectl -n <ns> logs job/<backup-job>
```

Trigger a backup now (for example, after a restore drill):

```sh
kubectl -n <ns> create -f - <<'YAML'
apiVersion: k8up.io/v1
kind: Backup
metadata:
  generateName: manual-
spec:
  backend:
    s3:
      bucket: k8up-<ns>
YAML
```

## Restoring

### A PVC (example: a Minecraft world)

```sh
kubectl -n minecraft-grass-gang scale sts/minecraft --replicas=0
kubectl -n minecraft-grass-gang get snapshots   # pick an ID; paths are /data/<pvc>
kubectl -n minecraft-grass-gang create -f - <<'YAML'
apiVersion: k8up.io/v1
kind: Restore
metadata:
  generateName: restore-
spec:
  snapshot: <snapshot-id>
  restoreMethod:
    folder:
      claimName: minecraft-data
  backend:
    s3:
      bucket: k8up-minecraft-grass-gang
YAML
```

The restore writes files over the PVC's existing content. It doesn't
delete files that aren't in the snapshot, so for a clean rollback, move
the old `world*` directories aside first. Then connect, and mc-router
starts the server.

### Postgres (speedtest-tracker)

Use restic directly. The password is in the `k8up-global` Secret.

```sh
export RESTIC_REPOSITORY=s3:http://10.100.10.15:30320/k8up-speedtest-tracker
export RESTIC_PASSWORD=... AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=...
restic snapshots
restic dump latest /speedtest-tracker-postgres.sql > dump.sql
kubectl -n speedtest-tracker exec -i deploy/speedtest-tracker-db -- \
  sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < dump.sql
```
