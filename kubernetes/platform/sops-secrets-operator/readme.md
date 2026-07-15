# sops-secrets-operator

Watches `SopsSecret` custom resources and decrypts them into real
`Secret`s in-cluster. This is what makes secrets safe to commit: the
`SopsSecret` YAML in git is SOPS-encrypted (`age`), and only this
operator -- holding the private key -- can turn it into something usable.

Chosen over Sealed Secrets specifically because the `age` private key is
generated and backed up by *you*, independent of any cluster, and works
across multiple clusters unchanged -- directly relevant to the
multi-cluster/failover goal in `.claude-plan.md`. Sealed Secrets generates
its key *inside* the cluster's controller; lose the cluster without a
separate backup and every sealed secret is permanently unrecoverable, and
moving to a second cluster means re-sealing everything against a new key.

## One-time setup (already done on this cluster, 2026-07)

1. Generate an `age` keypair -- **back this up somewhere durable** (password
   manager, etc.); it's the only way to decrypt anything encrypted against
   it, on this cluster or any future one:

   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

2. The public key goes in `.sops.yaml` at the repo root (already done --
   `age1a4v9rkhc0lmv9ju0yzsp5gmas7hu982q23jrq4y44dhuqgcsua4qe3wl9x`). The
   private key stays local, never committed.

3. The cluster needs its own copy of the private key so the operator can
   decrypt -- created once, by hand, same as every other "bootstrap"
   secret in this repo:

   ```bash
   kubectl create secret generic sops-age-key \
     --namespace sops-secrets-operator \
     --from-file=keys.txt=$HOME/.config/sops/age/keys.txt
   ```

4. Install:

   ```bash
   helm repo add sops-secrets-operator https://isindir.github.io/sops-secrets-operator/
   kubectl apply -f 00-namespace.yaml
   helm install sops-secrets-operator sops-secrets-operator/sops-secrets-operator \
     --namespace sops-secrets-operator \
     --version 0.28.0 \
     -f values.yaml \
     --wait --timeout 180s
   ```

**If this cluster is ever rebuilt**: step 3 is the only manual step that
needs redoing (assuming you kept the `age` key from step 1 backed up
somewhere) -- everything else, including every secret encrypted against
that key, comes back from git as-is.

## Adding a new secret

1. Write a plaintext `SopsSecret` manifest under
   `kubernetes/<platform-or-apps>/<component>/secrets/<name>.sops.yaml`:

   ```yaml
   apiVersion: isindir.github.com/v1alpha3
   kind: SopsSecret
   metadata:
     name: my-secret
     namespace: my-namespace
   spec:
     secretTemplates:
       - name: my-secret
         stringData:
           key: real-value-here
   ```

2. Encrypt it in place (matches `.sops.yaml`'s path rule, so plain `sops -e -i` finds the right key automatically):

   ```bash
   sops --encrypt --in-place kubernetes/<path>/secrets/<name>.sops.yaml
   ```

3. Commit the now-encrypted file. `git diff` on it afterward shows ciphertext,
   never plaintext -- safe to commit, safe to review in a PR.

4. `kubectl apply -f` it (or let Argo CD pick it up once it's part of an
   Application's source path) -- the operator creates the real `Secret`
   automatically.

To edit an existing one: `sops kubernetes/<path>/secrets/<name>.sops.yaml`
opens it decrypted in `$EDITOR`, re-encrypts on save.

## Migrating the existing manual secrets

Three secrets currently exist only as live, hand-created `Secret`s (never
in git): `cloudflare-api-token` (cert-manager and external-dns namespaces,
same value, two copies) and `cloudflare-tunnel-token` (cloudflared
namespace). Migrating them means writing a `SopsSecret` with the real
value and encrypting it -- see each platform component's own readme for
the exact `SopsSecret` manifest to use. Once applied and confirmed
working, the original hand-created `Secret` can be deleted (the operator
will recreate an identical one it now owns).
