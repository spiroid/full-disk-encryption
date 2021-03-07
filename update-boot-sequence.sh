#!/bin/bash
# Unofficial bash stric mode : http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

bootloaderid=${1:-archlinux}

echo "updating boot sequence with efi bootload id: ${bootloaderid}"

# Reinstall / update kernel to latest version
# This ensures that the kernel is present and up to date on the usb-key boot partition
sudo pacman -Sy --noconfirm linux

# Update initramfs
mkinitcpio -p linux

# Update grub config and install on efi partition
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=$bootloaderid --removable --recheck
