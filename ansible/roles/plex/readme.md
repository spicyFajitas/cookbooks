# Plex

This role is for plex. Plex is decoupled from my media stack so that I can run it on a different host that has an intel CPU for hardware transcoding.

## Meta

This role also includes the SSH role is a dependency since I need my SSH keys on the fedora host.

## NVidia Drivers

```shell
dnf install -y libva-nvidia-drivers
dnf install -y nvidia-container-toolkit
vim /etc/default/grub

# add this next line
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"  # 

grub2-mkconfig -o /boot/grub2/grub.cfg

root@fedora:/opt/media# sudo nvidia-ctk runtime configure --runtime=docker
INFO[0000] Loading config from /etc/docker/daemon.json  
INFO[0000] Wrote updated config to /etc/docker/daemon.json 
INFO[0000] It is recommended that docker daemon be restarted. 
root@fedora:/opt/media# sudo systemctl daemon-reload 
root@fedora:/opt/media# systemctl restart docker
root@fedora:/opt/media# 

```

reference: <https://medium.com/@PlanB./how-to-set-up-nvidia-gpu-passthrough-for-plex-on-proxmox-a-troubleshooting-guide-493a0ce72595#:~:text=Plex%20Not%20Detecting%20the%20GPU,enabled%20can%20block%20driver%20installations.>
