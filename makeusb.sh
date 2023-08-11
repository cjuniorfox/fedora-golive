#!/bin/bash
set -x 

. ./environment.sh

wipefs -a $USB_DRIVE

parted --script $USB_DRIVE \
    mklabel gpt \
    mkpart primary fat32 2048s $EFI_SIZE \
    name 1 EFI \
    set 1 esp on \
    mkpart primary ext4  $EFI_SIZE $LIVE_SIZE \
    name 2 ${LABEL_ROOT} \
    mkpart primary ext4 $LIVE_SIZE 100% \
    name 3 ${LABEL_ROOT}

mkfs.msdos -n EFI -F32 "${USB_DRIVE}1"
mkfs.ext4 "${USB_DRIVE}2" -L ${LABEL_ROOT}
mkfs.ext4 "${USB_DRIVE}3" -L ${LABEL_HOME}

UUID_ROOT=$(blkid -o value -s UUID ${USB_DRIVE}2)

mkdir ${MNT_EFI}

mount "${USB_DRIVE}1" ${MNT_EFI}
mkdir -p ${MNT_EFI}/EFI/{fedora,BOOT}
cp -v /boot/efi/EFI/BOOT/* ${MNT_EFI}/EFI/BOOT/
find /boot/efi/EFI/fedora -name *.efi -exec cp -v {} ${MNT_EFI}/EFI/fedora \;
cp /boot/efi/EFI/fedora/BOOTX64.CSV ${MNT_EFI}/EFI/fedora/

cat << EOF | tee >> ${MNT_EFI}/EFI/fedora/grub.cfg
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
insmod ext4

set timeout=60
### END /etc/grub.d/00_header ###

search --no-floppy --set=root -u '${UUID_ROOT}'

### BEGIN /etc/grub.d/10_linux ###
menuentry 'Start Fedora' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /vmlinuz root=live:UUID=${UUID_ROOT}  rd.live.image rd.live.overlay=UUID=${UUID_ROOT} quiet rhgb
	initrdefi /initrd.img
}
menuentry 'Copy to RAM & Start Fedora' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /vmlinuz root=live:UUID=${UUID_ROOT} rd.live.ram=1 rd.live.image rd.live.overlay=UUID=${UUID_ROOT} quiet rhgb
	initrdefi /initrd.img
}
menuentry 'Test this media & start Fedora' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /vmlinuz root=live:UUID=${UUID_ROOT} rd.live.image rd.live.overlay=UUID=${UUID_ROOT} rd.live.check quiet
	initrdefi /initrd.img
}
submenu 'Troubleshooting -->' {
	menuentry 'Start Fedora in basic graphics mode' --class fedora --class gnu-linux --class gnu --class os {
		linuxefi /vmlinuz root=live:UUID=${UUID_ROOT} rd.live.image rd.live.overlay=UUID=${UUID_ROOT} nomodeset quiet rhgb
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
truncate -s 2G "${MNT_ROOT}/LiveOS/overlay-${LABEL_ROOT}-${UUID_ROOT}"
chmod u+rw,g-rwx,o-rwx "${MNT_ROOT}/LiveOS/overlay-${LABEL_ROOT}-${UUID_ROOT}"
cp -Rv root/* ${MNT_ROOT}/
umount ${MNT_ROOT}/
rm -rfv ${MNT_ROOT}/
#mkdir __home
#mount "${USB_DRIVE}3" __home
#dd if=/dev/zero of=__home/persistent-overlay.img bs=512M count=4
#chmod u+rw,g-rwx,o-rwx __home/persistent-overlay.img
#umount __home
#rm -rfv __home
