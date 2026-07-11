# Kubernetes

## Overview

The homelab cluster is k3s, single control-plane node (`k3s-server-01`,
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
