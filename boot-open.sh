#!/bin/bash
# Unofficial bash stric mode : http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Initialize script variables
usb_stick=${1:-}
if [[ -z "$usb_stick" ]]; then
    echo "usage: $0 usb_stick_device"
    exit 1
fi

efi_partition="${usb_stick}1"
boot_partition="${usb_stick}2"

# Mount efi partition
mount $efi_partition /efi

# Open luks container for boot partition
cryptsetup luksOpen $boot_partition luks_boot
mount /dev/mapper/luks_boot /boot
