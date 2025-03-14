# Talos Linux Kubernetes Setup

- [Talos Linux Kubernetes Setup](#talos-linux-kubernetes-setup)
  - [Prereqs](#prereqs)
    - [Helper VM](#helper-vm)
  - [Bootstrap Talos](#bootstrap-talos)
  - [Install Kubectl](#install-kubectl)
  - [Export Kubeconfig](#export-kubeconfig)
  - [Add QEMU Guest Agent](#add-qemu-guest-agent)
  - [Install CNI](#install-cni)
  - [Cleanup](#cleanup)
    - [Delete Node After Rename](#delete-node-after-rename)

## Prereqs

### Helper VM

Install some tools

```shell
sudo apt install git
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

## Bootstrap Talos

```shell
export CONTROL_PLANE_IP=10.100.10.31
export WORKER_IP=10.100.10.32

talosctl get disks --insecure --nodes $CONTROL_PLANE_IP
# we can see the disks used in my VMs are /dev/sda, so we do not have to change the installation disk settings

# QEMU guest agent support
talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir _out --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.9.2
```

The default service subnet overlaps with my IP address space (10.100.10.0/23)

`vim _out/controlplane.yaml`
`vim _out/worker.yaml`

```diff
        serviceSubnets:
-            - 10.96.0.0/12
+            - 10.40.0.0/12
```

```shell
# Create Control Plane Node
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file _out/controlplane.yaml

# Create Worker Node
talosctl apply-config --insecure --nodes $WORKER_IP --file _out/worker.yaml

# Using the Cluster
export TALOSCONFIG="_out/talosconfig"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP

# Bootstrap Etcd
talosctl bootstrap
```

## Install Kubectl

```shell
# Install kubectl
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
sudo apt-get update
sudo apt-get install -y kubectl
```

## Export Kubeconfig

```shell
# Connect to cluster with kubeconfig
# this does not persist
talosctl kubeconfig --nodes 10.100.10.31 --endpoints 10.100.10.31 --talosconfig=_out/talosconfig

# to persist talos config, copy talosconfig to ~/.talos/config
root@talos-helper:~/_out# talosctl get members
error constructing client: failed to determine endpoints
root@talos-helper:~# cp .talos/talosconfig .talos/config
root@talos-helper:~# talosctl get members
NODE           NAMESPACE   TYPE     ID              VERSION   HOSTNAME        MACHINE TYPE   OS               ADDRESSES
10.100.10.31   cluster     Member   talos-41x-omp   1         talos-41x-omp   controlplane   Talos (v1.9.3)   ["10.100.10.31"]
10.100.10.31   cluster     Member   talos-fzs-t6w   1         talos-fzs-t6w   worker         Talos (v1.9.3)   ["10.100.10.32"]

```

Alternative:

```shell
talosctl kubeconfig .
export KUBECONFIG=./kubeconfig
kubectl get nodes
```

## Add QEMU Guest Agent

```shell
# https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=metal&target=metal&version=1.9.3
root@talos-helper:~# talosctl upgrade --nodes 10.100.10.31 --image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.9.3
root@talos-helper:~# talosctl upgrade --nodes 10.100.10.32 --image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.9.3
```

## Install CNI

```shell
helm install \
    cilium \
    cilium/cilium \
    --version 1.15.6 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=false \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup
```

## Cleanup

### Delete Node After Rename

```shell
kubectl delete node <node-name>
```