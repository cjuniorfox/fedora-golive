#!/bin/bash
set -x 

. ./environment.sh
RSYNC='rsync -axHAWXS --numeric-ids --info=progress2'
UUID_ROOT=$(blkid -o value -s UUID ${USB_DRIVE}2)

mkdir ${MNT_EFI}

mount "${USB_DRIVE}1" ${MNT_EFI}
mkdir -p ${MNT_EFI}/EFI/{fedora,BOOT}
${RSYNC} /boot/efi/EFI/BOOT/* ${MNT_EFI}/EFI/BOOT/
find /boot/efi/EFI/fedora -name *.efi -exec cp -v {} ${MNT_EFI}/EFI/fedora \;
cp /boot/efi/EFI/fedora/BOOTX64.CSV ${MNT_EFI}/EFI/fedora/

cat << EOF | tee ${MNT_EFI}/EFI/fedora/grub.cfg
set default="0"

function load_video {
  insmod efi_gop
  insmod efi_uga
  insmod video_bochs
  insmod video_cirrus
  insmod all_video
}

load_video
set gfxpayload=keep
insmod gzio
insmod part_gpt
insmod ext2
insmod xfs

set timeout=60
### END /etc/grub.d/00_header ###

search --no-floppy --set=root -u '${UUID_ROOT}'

### BEGIN /etc/grub.d/10_linux ###
menuentry 'Start Fedora' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /vmlinuz root=live:UUID=${UUID_ROOT}  rd.live.image quiet rhgb #rd.live.overlay=UUID=${UUID_ROOT}
	initrdefi /initrd.img
}
menuentry 'Copy to RAM & Start Fedora' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /vmlinuz root=live:UUID=${UUID_ROOT} rd.live.ram=1 rd.live.image quiet rhgb #rd.live.overlay=UUID=${UUID_ROOT}
	initrdefi /initrd.img
}
menuentry 'Test this media & start Fedora' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /vmlinuz root=live:UUID=${UUID_ROOT} rd.live.image rd.live.check #rd.live.overlay=UUID=${UUID_ROOT}
	initrdefi /initrd.img
}
submenu 'Troubleshooting -->' {
	menuentry 'Start Fedora in basic graphics mode' --class fedora --class gnu-linux --class gnu --class os {
		linuxefi /vmlinuz root=live:UUID=${UUID_ROOT} rd.live.image nomodeset quiet rhgb #rd.live.overlay=UUID=${UUID_ROOT}
		initrdefi /initrd.img
	}
}
EOF

cp ${MNT_EFI}/EFI/fedora/grub.cfg ${MNT_EFI}/EFI/BOOT/BOOT.conf
umount ${MNT_EFI}
rm -rfv ${MNT_EFI}
mkdir ${MNT_ROOT}
mount "${USB_DRIVE}2" ${MNT_ROOT}
mkdir -p ${MNT_ROOT}/LiveOS
#truncate -s 2G "${MNT_ROOT}/LiveOS/overlay-${LABEL_ROOT}-${UUID_ROOT}"
#chmod u+rw,g-rwx,o-rwx "${MNT_ROOT}/LiveOS/overlay-${LABEL_ROOT}-${UUID_ROOT}"
${RSYNC} root/* ${MNT_ROOT}/
umount ${MNT_ROOT}/
mount root/LiveOS/squashfs.img ${MNT_ROOT}
mount ${MNT_ROOT}/LiveOS/rootfs.img ${MNT_ROOT}
mkdir ${MNT_HOME} 
mount "${USB_DRIVE}3" "${MNT_HOME}" 
${RSYNC} ${MNT_ROOT}/home/* ${MNT_HOME}/
umount ${MNT_ROOT} && umount ${MNT_ROOT} && rm -rfv ${MNT_ROOT}
umount ${MNT_HOME} && rm -rfv ${MNT_HOME}
