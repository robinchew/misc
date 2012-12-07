mkarchiso -v init
mkarchiso -v -p "openssh vim git xorg xorg-xinit xterm blackbox gparted wicd wicd-gtk terminal chromium flashplugin mplayer acpi alsa-utils e2fsprogs fuse sshfs" install

cp /usr/lib/initcpio/hooks/archiso work/root-image/usr/lib/initcpio/hooks
cp /usr/lib/initcpio/install/archiso work/root-image/usr/lib/initcpio/install

cat > work/root-image/etc/mkinitcpio-archiso.conf << EOF
HOOKS="base udev archiso pata scsi sata usb fw filesystems usbinput"
COMPRESSION="xz"
EOF

# Assuming your PC architure is i686
mkdir work/root-image/boot/i686
mkarchiso -r "mkinitcpio -c /etc/mkinitcpio-archiso.conf -k /boot/vmlinuz-linux -g /boot/i686/archiso.img" run

# mkinitcpio above could have created:
# vmlinuz and archiso.img
# PLEASE CHECK!

mkdir -p work/iso/arch/boot/i686
mv work/root-image/boot/vmlinuz-linux work/iso/arch/boot/i686/vmlinuz
mv work/root-image/boot/i686/archiso.img work/iso/arch/boot/i686/archiso.img

# Syslinux
mkdir -p work/iso/arch/boot/syslinux
cat > work/iso/arch/boot/syslinux/syslinux.cfg << EOF
DEFAULT menu.c32
PROMPT 0G
MENU TITLE Arch Linux
TIMEOUT 300

LABEL arch
MENU LABEL Arch Linux
LINUX /arch/boot/i686/vmlinuz
INITRD /arch/boot/i686/archiso.img
APPEND archisolabel=MY_ARCH

ONTIMEOUT arch
EOF

# menu.c32
cp work/root-image/usr/lib/syslinux/menu.c32 work/iso/arch/boot/syslinux/

# isolinux
mkdir work/iso/isolinux
cp work/root-image/usr/lib/syslinux/isolinux.bin work/iso/isolinux/
cp work/root-image/usr/lib/syslinux/isohdpfx.bin work/iso/isolinux/

cat > work/iso/isolinux/isolinux.cfg << EOF
DEFAULT loadconfig

LABEL loadconfig
  CONFIG /arch/boot/syslinux/syslinux.cfg
  APPEND /arch/boot/syslinux/
EOF

# aitab
cat > work/iso/arch/aitab << EOF
# <img>         <mnt>                 <arch>   <sfs_comp>  <fs_type>  <fs_size>
root-image      /                     i686     xz          ext4       50%
EOF

# Prepare & create iso
mkarchiso prepare
mkarchiso -L "MY_ARCH" iso "my-arch.iso"

# https://wiki.archlinux.org/index.php/Archiso
