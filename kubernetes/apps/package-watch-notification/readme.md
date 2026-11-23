# kernel-watch

Daily CronJob (08:17 America/Los_Angeles) that checks Launchpad for the
latest published version of each watched Ubuntu source package and emails a
report **only when a version changed** since the last run.

Only the Ubuntu primary archive is queried, in the `Release`, `Security` and
`Updates` pockets. `-proposed` is skipped, and Ubuntu Pro kernels (ESM, FIPS,
Livepatch) are never seen: they are published to separate private archives.

## What's here

- `config/kernel_watch.py`: the checker. Python stdlib only, so it runs on
  plain `python:3.13-slim`.
- `config/packages.json`: the watch list. Both files are mounted at
  `/config` through `configMapGenerator`, so editing either one and merging
  is enough; the next run picks it up.
- `01-pvc.yaml`: `/state/state.json`, the last version seen per package. Not
  backed up by k8up. If it's lost, the next run emails every package once as
  "first run" and then carries on.
- `02-cronjob.yaml`
- `secrets/kernel-watch-smtp.sops.yaml`: Gmail SMTP credentials (see below).

## Watching more packages

Add an entry to `config/packages.json`. All changes go out in one email.

```json
[
  { "name": "linux", "series": "noble", "version_prefix": "6.8.0-" },
  { "name": "linux-hwe-6.8", "series": "jammy", "version_prefix": "6.8.0-" },
  { "name": "linux-aws", "series": "noble" },
  { "name": "openssl", "series": "noble", "pockets": ["Security"] }
]
```

| Field            | Required | Meaning                                                              |
| ---------------- | -------- | -------------------------------------------------------------------- |
| `name`           | yes      | Source package name, as in `apt-cache showsrc` / Launchpad           |
| `series`         | yes      | Ubuntu codename (`noble`, `jammy`, ...)                              |
| `version_prefix` | no       | Only versions starting with this count (e.g. `6.8.0-`)               |
| `pockets`        | no       | Default `["Release", "Security", "Updates"]`; add `"Proposed"` to include `-proposed` |

Each `name`/`series`/`version_prefix` combination is tracked separately.

## Secret

Mail goes out the same way as Proxmox's postfix relay
(`ansible/roles/proxmox/templates/main.cf.j2`, `docs/src/homelab/proxmox.md`'s
"Email Alerts"): Gmail at `smtp.gmail.com:587` with STARTTLS, using an app
password. `02-cronjob.yaml` sets `SMTP_HOST`, `SMTP_PORT` and `MAIL_FROM`
(`Linux Server <linux-server@adfulton.com>`, the From address postfix's
`smtp_header_checks` rewrites to).

The credentials are the same ones postfix uses, from
`ansible/roles/proxmox/vaults/production.yml`:

| SopsSecret key  | Ansible vault var                    |
| --------------- | ------------------------------------ |
| `SMTP_USERNAME` | `gmail_username`                     |
| `SMTP_PASSWORD` | `app_password`                       |
| `MAIL_TO`       | address(es) to send to, comma-separated |

```bash
# from ansible/
ansible-vault view roles/proxmox/vaults/production.yml
# copy values into the placeholders, then
sops --encrypt --in-place kubernetes/apps/kernel-watch/secrets/kernel-watch-smtp.sops.yaml
```

Same `SopsSecret` flow as the rest of the repo, see
`kubernetes/platform/sops-secrets-operator/readme.md`.

Gmail only keeps the custom From address if it's set up as a "Send mail as"
alias on that account; otherwise Gmail replaces it with the account's own
address.

## Testing

```bash
kubectl -n kernel-watch create job --from=cronjob/kernel-watch manual-$(date +%s)
kubectl -n kernel-watch logs -f job/manual-<timestamp>
```

The first run always sends one email, which confirms SMTP works. After that,
an email goes out only when a version changes. If a package lookup fails, the
Job exits non-zero but still emails any changes it did find. State is saved
only after a successful send, so a failed send is retried the next day.
