# Kubernetes

## Overview

The homelab cluster is k3s, single control-plane node (`k3s`,
10.100.10.12, installed via `ansible/roles/k3s_server` -- see
`.claude-plan.md` for the full topology and buildout plan).

**Don't write cluster kubeconfigs to the default `~/.kube/config`** if you
already use `kubectl` against another cluster (e.g. a work cluster with its
own OIDC login) -- overwriting it replaces that context and you'll lose it.
Use a separate file + `KUBECONFIG` env var per cluster instead:

```shell
mkdir -p ~/.kube
ssh root@10.100.10.12 "cat /etc/rancher/k3s/k3s.yaml" \
  | sed 's/127.0.0.1/10.100.10.12/' > ~/.kube/k3s-homelab.yaml
chmod 600 ~/.kube/k3s-homelab.yaml

# use it for one command:
KUBECONFIG=~/.kube/k3s-homelab.yaml kubectl get nodes

# or for a whole shell session:
export KUBECONFIG=~/.kube/k3s-homelab.yaml
```

To merge it into `kubectl`'s multi-context config instead of a standalone
file (lets you `kubectl config use-context k3s-homelab` to switch):

```shell
KUBECONFIG=~/.kube/config:~/.kube/k3s-homelab.yaml kubectl config view --flatten > /tmp/merged
mv /tmp/merged ~/.kube/config
kubectl config rename-context default k3s-homelab
```

## Layout

```text
kubernetes/
  platform/           # cluster-wide infra, installed once, apps depend on it
    cert-manager/
    external-dns/
    cloudflared/
  apps/               # actual workloads
    magic/
```

No Helm/ArgoCD-managed GitOps yet (that's `.claude-plan.md` step 9) --
until then, this directory is the source of truth in the sense that "what's
in git is what you'd run to reproduce the cluster from scratch," not in the
sense that it's continuously reconciled. Each component's own `readme.md`
has the exact apply commands; run them in the order the top-level
`readme.md`/`.claude-plan.md` install order lists (platform pieces before
the apps that depend on them). Every component that installs via Helm
checks in a pinned chart version + `values.yaml` instead of ad hoc `--set`
flags, specifically so the installed config isn't tribal knowledge.

Anything genuinely secret (API tokens, tunnel credentials) is deliberately
**not** in git yet -- no Sealed Secrets/SOPS in place (`.claude-plan.md`'s
"No secrets management" gap). Each component's readme says what Secret it
needs and how to create it by hand in the meantime.
