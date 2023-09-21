#!/bin/bash
. ./environment.sh
echo "Removing old unused kernel modules"
MOUNTPOINTS="/dev /run /proc /sys /tmp"
for i in ${MOUNTPOINTS}; do
	mount -B ${i} ${MNT_ROOT}${i};
done;
chroot ${MNT_ROOT} << EOF
  kernel_ver="$(ls -t /usr/lib/modules/ | grep -e '.x86_64$' | head -n1)"
  dnf remove $(dnf repoquery --installonly -q | grep -v "${kernel_ver}")
EOF
for i in ${MOUNTPOINTS}; do
	umount ${MNT_ROOT}${i};
done;
