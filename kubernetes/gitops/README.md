# GitOps Bootstrap (k3s)

## Prereqs on k3s nodes

- Install k3s with MetalLB and Traefik managed by GitOps (disable servicelb and Traefik in k3s):

```shell
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.29.6+k3s1 sh -s - --disable=servicelb --disable=traefik
```

- Longhorn host dependencies (Ubuntu/Debian example):

```shell
sudo apt-get update
sudo apt-get install -y open-iscsi
sudo systemctl enable --now iscsid
```

## One-time bootstrap

1) Install Argo CD:

```shell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.10.7/manifests/install.yaml
```

2) Point Argo CD at this repo:

- Update `repoURL` in `kubernetes/gitops/bootstrap/app-of-apps.yaml`.
- Update `repoURL` in:
  - `kubernetes/gitops/apps/metallb/config-app.yaml`
  - `kubernetes/gitops/apps/external-dns/config-app.yaml`
  - `kubernetes/gitops/apps/velero/config-app.yaml`

3) Apply the app-of-apps:

```shell
kubectl apply -f kubernetes/gitops/bootstrap/app-of-apps.yaml
```

## Post-bootstrap configuration

- MetalLB pool: edit `kubernetes/gitops/apps/metallb/config/ipaddresspool.yaml` with your LAN range.
- External DNS:
  - Put your Cloudflare API token in `kubernetes/gitops/apps/external-dns/config/secret.sops.yaml`.
  - Update `domainFilters` in `kubernetes/gitops/apps/external-dns/app.yaml`.
- Velero:
  - Provide S3-compatible creds in `kubernetes/gitops/apps/velero/config/secret.sops.yaml`.
  - Set the `s3Url`/bucket in `kubernetes/gitops/apps/velero/app.yaml` for TrueNAS.
- NFS provisioner (optional):
  - Update `kubernetes/gitops/apps/nfs-provisioner/app.yaml` with your NFS server/path.
  - If you only have CIFS/SMB, use an SMB CSI driver instead of this chart.
- SMB CSI driver:
  - Update the SMB share in `kubernetes/gitops/apps/smb-csi/config/storageclass.yaml`.
  - Put SMB creds in `kubernetes/gitops/apps/smb-csi/config/secret.sops.yaml`.
  - The driver is installed via `kubernetes/gitops/apps/smb-csi/app.yaml` and config via `kubernetes/gitops/apps/smb-csi/config-app.yaml`.

## SOPS secrets

1) Create an age keypair:

```shell
age-keygen -o ~/.config/sops/age/keys.txt
```

2) Update `.sops.yaml` with your age public key.

3) Encrypt secrets in place:

```shell
sops -e -i kubernetes/gitops/apps/external-dns/config/secret.sops.yaml
sops -e -i kubernetes/gitops/apps/velero/config/secret.sops.yaml
sops -e -i kubernetes/gitops/apps/smb-csi/config/secret.sops.yaml
```

4) Argo CD does not decrypt SOPS by default. Install a SOPS plugin (ksops or argocd-vault-plugin) in `argocd-repo-server` before syncing.

## Notes

- k3s uses flannel by default, so no extra flannel manifests are required.
- If you want to replace Traefik with another ingress, add that as another Argo CD application.
