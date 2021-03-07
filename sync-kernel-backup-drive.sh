#!/bin/bash
# Unofficial bash stric mode : http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# To be run as root or with sudo

# Initialize script variables
usb_stick=${1:-}
if [[ -z "$usb_stick" ]]; then
    echo "usage: $0 usb_device backup_usb_device"
    exit 1
fi

backup_usb_stick=${2:-}
if [[ -z "$backup_usb_stick" ]]; then
    echo "usage: $0 usb_device backup_usb_device"
    exit 1
fi

boot_partition="${usb_stick}2"
bak_boot_partition="${backup_usb_stick}2"


# Open lunks containers for both devices
cryptsetup luksOpen $boot_partition luks_boot
cryptsetup luksOpen $bak_boot_partition luks_boot_bak


# Create tmp directories and mount partitions
mkdir -p /tmp/boot /tmp/boot_bak
mount /dev/mapper/luks_boot /tmp/boot
mount /dev/mapper/luks_boot_bak /tmp/boot_bak


# Copy liux kernel file to backup location
cp -a /tmp/boot/vmlinuz-linux /tmp/boot_bak

# Cleanup
umount /tmp/boot
umount /tmp/boot_bak
cryptsetup luksClose /dev/mapper/luks_boot
cryptsetup luksClose /dev/mapper/luks_boot_bak
