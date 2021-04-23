#!/bin/bash
# Unofficial bash stric mode : http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Initialize script variables
usb_stick=${1:-}
if [[ -z "$usb_stick" ]]; then
    echo "usage: $0 usb_stick_device hard_drive_device"
    exit 1
fi

hard_drive=${2:-}
if [[ -z "$hard_drive" ]]; then
    echo "usage: $0 usb_stick_device hard_drive_device"
    exit 1
fi

efi_partition="${usb_stick}1"
boot_partition="${usb_stick}2"
root_partition="${hard_drive}p1"
swap_partition="${hard_drive}p2"
mount_boot=/tmp/boot

# Prepare directories and open luks container for boot partition
mkdir -p $mount_boot
cryptsetup luksOpen $boot_partition luks_boot
mount /dev/mapper/luks_boot $mount_boot

# Unlock swap & root paritions from using luks header and keys
cryptsetup luksOpen $root_partition --header $mount_boot/luks_root_header --key-file $mount_boot/luks_root_keyfile luks_root
cryptsetup luksOpen $swap_partition --header $mount_boot/luks_swap_header --key-file $mount_boot/luks_swap_keyfile luks_swap

# Activate swap device
swapon /dev/mapper/luks_swap

# cleanup
# unmount temp boot
umount $mount_boot

# Partitions
# Mount with subvolumes and correct options
mount -o compress=lzo,noatime,space_cache,autodefrag,ssd,subvol=@ /dev/mapper/luks_root /mnt
mount -o compress=lzo,noatime,space_cache,autodefrag,ssd,subvol=@var /dev/mapper/luks_root /mnt/var
mount -o compress=lzo,noatime,nodev,nosuid,noexec,space_cache,autodefrag,ssd,subvol=@varlog /dev/mapper/luks_root /mnt/var/log
mount -o compress=lzo,noatime,space_cache,autodefrag,ssd,subvol=@snapshots /dev/mapper/luks_root /mnt/.snapshots
mount -o compress=lzo,noatime,nodev,nosuid,space_cache,autodefrag,ssd,subvol=@home /dev/mapper/luks_root /mnt/home

# Mount boot parition
mount /dev/mapper/luks_boot /mnt/boot

# Mount EFI Partition
mount $efi_partition /mnt/efi

# Chroot
# Change root into the new system:
arch-chroot /mnt


# In the chroot, launch
# /home/spiroid/bin/update-boot-sequence.sh
# and then ctrd+D

# Cleanup

umount /mnt/efi
umount /mnt/boot
umount /mnt/home
umount /mnt/.snapshots
umount /mnt/var/log
umount /mnt/var
umount /mnt


cryptsetup luksClose luks_boot
cryptsetup luksClose luks_root
swap_off /dev/mapper/luks_swap
cryptsetup luksClose luks_swap
