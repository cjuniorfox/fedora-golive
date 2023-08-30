#!/bin/bash
. ./environment.sh
echo "Cleaning any package installation"
MOUNTPOINTS="/dev /run /proc /sys /tmp"
for i in ${MOUNTPOINTS}; do
	mount -B ${i} ${MNT_ROOT}${i};
done;
chroot ${MNT_ROOT} << EOF
  dnf clean packages
EOF
for i in ${MOUNTPOINTS}; do
	umount ${MNT_ROOT}${i};
done;
