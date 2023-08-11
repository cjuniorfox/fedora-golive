#!/bin/bash
set -x

mkdir -p {root/LiveOS,__root}
truncate -s "$( expr $(df | grep '/$' | awk '{print $3}') +  1000000)"K root/LiveOS/rootfs.img
mkfs.ext4 -L root root/LiveOS/rootfs.img
mount -o loop root/LiveOS/rootfs.img __root/
setenforce 0
rsync -axHAWXS --numeric-ids --info=progress2 --exclude=/home/* --exclude=/tmp/* --exclude=/var/tmp/* --exclude=/lost+found/ --exclude=/var/lib/libvirt/images/ / __root/
setenforce 1
cat << EOF | tee __root/etc/fstab
#/dev/disk/by-label/home-golive /home/ ext4 defaults,nofail 0 0
vartmp   /var/tmp    tmpfs   defaults   0  0
EOF

home_dir=/home
for user in $(ls $home_dir); do
	if [ -d "$home_dir/$user" ]; then
		mkdir -p "__root/home/$user"
		cp -Rv /etc/skel/* "__root/home/$user/"
		chown -R $user:$user "__root/home/$user"
		chmod -R 700 "__root/home/$user"
	fi
done;

umount __root/
rm -rfv __root/
mksquashfs root/ root/LiveOS/squashfs.img 
rm -rfv root/LiveOS/rootfs.img

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
