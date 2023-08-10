# Kubernetes

## Overview
```shell
export KUBECONFIG=~/.kube/config


mkdir ~/.kube 2> /dev/null
sudo k3s kubectl config view --raw > "$KUBECONFIG"
chmod 600 "$KUBECONFIG"
```

You can add `KUBECONFIG=~/.kube/config` to your `~/.profile` or `~/.bashrc` to make it persist on reboot.
