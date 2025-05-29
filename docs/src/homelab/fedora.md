# Fedora Linux

- [Fedora Linux](#fedora-linux)
  - [Updating](#updating)
  - [Image-Builder Custom ISO](#image-builder-custom-iso)

## Updating

```shell
sudo dnf --refresh upgrade

sudo dnf system-upgrade download --releasever=42


sudo dnf system-upgrade reboot
```

## Image-Builder Custom ISO

```toml
name = "debug-iso"
description = "Adam's Debug Fedora ISO with my standard tools"
version = "0.0.1"
modules = []
groups = []

[[packages]]
name = "gdu"
version = "*"

[[packages]]
name = "htop"
version = "*"

[[packages]]
name = "btop"
version = "*"

[[packages]]
name = "curl"
version = "*"

[[packages]]
name = "fastfetch"
version = "*"
```

```shell
mkdir image-builder
cd image-builder/
vim debug-iso.toml
sudo composer-cli blueprints push debug-iso.toml 
sudo composer-cli blueprints list 
sudo composer-cli blueprints depsolve debug-iso
sudo composer-cli compose types
sudo composer-cli compose start debug-iso live-installer
sudo composer-cli compose status
sudo composer-cli compose image 9b077777-0c59-4612-be9e-39cfd1fc8d9a
mv 9b077777-0c59-4612-be9e-39cfd1fc8d9a-live-installer.iso fedora-40-adam.iso
```
