#!/bin/bash
. ./environment.sh
echo "Installing Moonlight"
MOUNTPOINTS="/dev /proc /run /sys /tmp"
for i in ${MOUNTPOINTS}; do
	mount -B ${i} ${MNT_ROOT}${i};
done;
chroot ${MNT_ROOT} << EOF
flatpak -y install com.moonlight_stream.Moonlight
EOF
for i in ${MOUNTPOINTS}; do
	umount ${MNT_ROOT}${i};
done;
