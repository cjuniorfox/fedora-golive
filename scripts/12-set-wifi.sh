#!/bin/bash
. ./environment.sh
echo "Dealing with the wifi"
MOUNTPOINTS="/dev /proc /run /sys /tmp"
for i in ${MOUNTPOINTS}; do
	mount -B ${i} ${MNT_ROOT}${i};
done;
chroot ${MNT_ROOT} << EOF
	nmcli connection modify Wifi\ prato ifname wlp0s20f3 
EOF
for i in ${MOUNTPOINTS}; do
	umount ${MNT_ROOT}${i};
done;
