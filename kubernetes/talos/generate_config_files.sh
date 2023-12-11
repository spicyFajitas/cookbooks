#!/bin/bash

CONTROL_PLANE_IP=10.100.10.31
WORKER_IP=10.100.10.32

export CONTROL_PLANE_IP=10.100.10.31
export WORKER_IP=10.100.10.32

printf "Exported control plane IP as $CONTROL_PLANE_IP\n"
printf "Exported worker node IP as $WORKER_IP\n"

talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir output --with-kubespan --with-secrets secrets.yaml --force

printf "Forcefully generated new configuration files in _out directory\n"

talosctl machineconfig patch output/controlplane.yaml --patch @patch.yaml -o outputacontrolplane-patched.yaml

printf "Patched output/controlplane.yaml file with patch.yaml and saved to new file at output/controlplane-patched.yaml.\n"