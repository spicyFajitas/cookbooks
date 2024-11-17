# Kubernetes

## Overview
```shell
# stock k8s
export KUBECONFIG=~/.kube/config

# k3s
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml 

mkdir ~/.kube 2> /dev/null
sudo k3s kubectl config view --raw > "$KUBECONFIG"
chmod 600 "$KUBECONFIG"
```

You can add `KUBECONFIG=~/.kube/config` to your `~/.profile` or `~/.bashrc` to make it persist on reboot.
