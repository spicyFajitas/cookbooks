# K3s

## Installation

```shell
curl -sfL https://get.k3s.io | sh -
```


```shell

wget https://get.k3s.io > k3s_install.sh

./k3s_install.sh --disable traefik --disable servicelb --flannel-iface=eno1

kubectl apply -f https://kube-vip.io/manifests/rbac.yaml

curl -sO https://raw.githubusercontent.com/JamesTurland/JimsGarage/main/Kubernetes/K3S-Deploy/kube-vip

kubectl apply -f https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

curl -sO https://raw.githubusercontent.com/JamesTurland/JimsGarage/main/Kubernetes/K3S-Deploy/ipAddressPool

kubectl apply -f ipAddressPool.yaml

kubectl apply -f https://raw.githubusercontent.com/inlets/inlets-operator/master/contrib/nginx-sample-deployment.yaml -n default

kubectl expose deployment nginx-1 --port=80 --type=LoadBalancer -n default

kubectl apply -f https://raw.githubusercontent.com/JamesTurland/JimsGarage/main/Kubernetes/K3S-Deploy/l2Advertisement.yaml

```
