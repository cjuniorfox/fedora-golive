#!/bin/bash
. ./environment.sh

mkdir -p {root/LiveOS,${MNT_ROOT}}
echo "Calculating the size of your installation"
SIZE="$(sudo rsync -axHAWXS --numeric-ids --stats --dry-run --exclude=/home/* --exclude=/tmp/* --exclude=/var/tmp/* --exclude=/lost+found/ --exclude=/var/lib/libvirt/images/ / /tmp/ 2> /dev/null | grep 'Total transferred file size' | awk '{print $5}' | sed 's/\.//g')"
#Size at 512 bytes/sector
SIZE=$(expr "$SIZE" / 512 \* 512)
echo "The installation size is  $(expr $SIZE / 1024 / 1024 )M"
truncate -s "$(expr ${SIZE} \* 3 / 2 )" root/LiveOS/rootfs.img
mkfs.ext4 -L root root/LiveOS/rootfs.img
mount -o loop root/LiveOS/rootfs.img ${MNT_ROOT}/
echo "Cloning the installation to the rootfs.img"
setenforce 0
rsync -axHAWXS --numeric-ids --info=progress2 --exclude=/home/* --exclude=/tmp/* --exclude=/var/tmp/* --exclude=/var/logs/* --exclude=/var/cache/* --exclude=/lost+found/ --exclude=/var/lib/libvirt/images/ / ${MNT_ROOT}/
setenforce 1
echo "Replacing the fstab"
cat << EOF | tee ${MNT_ROOT}/etc/fstab
#/dev/disk/by-label/${LABEL_HOME} /home/ ext4 defaults,nofail 0 0
vartmp   /var/tmp    tmpfs   defaults   0  0
EOF
echo "Running aditional scripts"
run-parts ./scripts/

umount ${MNT_ROOT}/
rm -rfv ${MNT_ROOT}/
echo "Creating squashed image"
mksquashfs root/ root/LiveOS/squashfs.img 
rm -rfv root/LiveOS/rootfs.img

echo "Generating the Kernel image"
cat << EOF | sudo tee /etc/dracut.conf.d/01-liveos.conf 
mdadmconf="no"
lvmconf="no"
squash_compress="xz"
add_dracutmodules+=" livenet dmsquash-live dmsquash-live-ntfs convertfs pollcdrom qemu qemu-net "
omit_dracutmodules+=" plymouth "
hostonly="no"
early_microcode="no"
EOF
dracut -f root/initrd.img
cp -v /boot/vmlinuz-$(uname -r) root/vmlinuz
