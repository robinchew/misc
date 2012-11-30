#!/bin/sh
if [ "$#" -ne 2 ];then
    echo ERROR
    echo Need 2 arguments:
    echo
    echo "    bootflash.sh /dir/file.iso /dev/sdb2"
    echo
    echo Note: MUST have number after /dev/sdb
    echo Note: Must run as root 
    exit 1 
fi

fs=`blkid $2|sed 's/.*TYPE="\(.*\)".*/\1/g'`

if [ "$fs" != "vfat" ];then
    echo ERROR
    echo $2 needs to be partitioned as vfat, use:
    echo
    echo "    mkfs.vfat $2"
    exit 1
fi

[ ! -d "iso" ] && mkdir iso
[ ! -d "usb" ] && mkdir usb

mount -o loop $1 iso 
mount $2 usb
[ -d "usb/arch" ] && rm -R usb/arch
cp -r iso/arch usb/
uuid=`blkid -o value $2|head -n 1`
sed -i "s:archisolabel=[^ ]\+:archisodevice=/dev/disk/by-uuid/$uuid:g" usb/arch/boot/syslinux/syslinux.cfg
extlinux --install usb/arch/boot/syslinux/
umount iso
umount usb

dev_sdx=`echo $2|sed -e 's/[0-9]\+$//'` # remove trailing number
sfdisk -A1 $dev_sdx # make partition 1 bootable
dd bs=440 conv=notrunc count=1 if=/usr/lib/syslinux/mbr.bin of=$dev_sdx
