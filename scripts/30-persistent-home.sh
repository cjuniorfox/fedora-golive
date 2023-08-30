#!/bin/bash
. ./environment.sh
BLOCK_DEVICE='/dev/disk/by-label/golive-home'
FSTYPE="$(blkid ${BLOCK_DEVICE} | awk -F'TYPE=' '{print $2}' | awk '{print $1}' | sed 's/"//g')"

MOUNTPOINTS="/dev /proc /run /sys /tmp"
for i in ${MOUNTPOINTS}; do
	mount -B ${i} ${MNT_ROOT}${i};
done;

chroot ${MNT_ROOT} << EOF
#mount ${BLOCK_DEVICE} /mnt &&
#   cp -rfvp /home/* /mnt/ 
#umount /mnt

cat << HEREDOC > /etc/systemd/system/home.mount
[Unit]
Description=Persistent Home folder
[Mount]
What=${BLOCK_DEVICE}
Where=/home
Type=${FSTYPE}
Options=defaults,nofail

[Install]
WantedBy=default.target
HEREDOC
systemctl daemon-reload
systemctl enable home.mount
EOF

for i in ${MOUNTPOINTS}; do
	umount ${MNT_ROOT}${i};
done;
