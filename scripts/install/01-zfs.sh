#!/usr/bin/env bash

# Set DISK
select ENTRY in $(ls /dev/disk/by-id/);
do
    DISK="/dev/disk/by-id/$ENTRY"
    echo "Installing ZFS on $ENTRY."
    break
done

# Boot part
sgdisk -a1 -n2:34:2047 -t2:EF02 $DISK
# EFI part
sgdisk -n3:1M:+512M -t3:EF00 $DISK
# ZFS part
sgdisk -n1:0:0 -t1:BF01 $DISK

# Create ZFS pool
zpool create -O mountpoint=none -R /mnt rpool $DISK-part1zpool create -O mountpoint=none -R /mnt rpool $DISK-part1

# ZFS filesystems
zfs create -o mountpoint=none rpool/root
zfs create -o mountpoint=legacy rpool/root/nixos
zfs create -o mountpoint=legacy rpool/home

# Mount filesystems
mount -t zfs rpool/root/nixos /mnt
mkdir /mnt/home
mount -t zfs rpool/home /mnt/home

# Format EFI part
mkfs.vfat $DISK-part3
mkdir /mnt/boot
mount $DISK-part3 /mnt/boot

nixos-generate-config --root /mnt