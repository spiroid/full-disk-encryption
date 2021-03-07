#!/bin/bash
# Unofficial bash stric mode : http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Unmount and close luks boot container
umount /boot
cryptsetup luksClose /dev/mapper/luks_boot
umount /efi
