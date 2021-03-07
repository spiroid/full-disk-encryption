#!/bin/bash
# Unofficial bash stric mode : http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Note: ${BASH_SOURCE%/*} refers to this script location
# @see: https://stackoverflow.com/questions/6659689/referring-to-a-file-relative-to-executing-script

# Initialize script variables
usb_stick=${1:-}
if [[ -z "$usb_stick" ]]; then
    echo "usage: $0 usb_stick_device"
    exit 1
fi

bootloaderid=${2:-archlinux}

# open usb boot stick
"${BASH_SOURCE%/*}/boot-open.sh" $usb_stick

# initramfs + grub updates
"${BASH_SOURCE%/*}/update-boot-sequence.sh" $bootloaderid

# Unmount and close luks boot container
"${BASH_SOURCE%/*}/boot-close.sh"
