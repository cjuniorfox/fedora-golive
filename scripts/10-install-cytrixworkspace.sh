#!/bin/bash
. ./environment.sh
echo "Installing Cytrix Workspace"
echo "Download ICAClient from Cytrix at the following URL: "
echo "https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html"
find /home/*/Downloads/ -iname ICAClient*.rpm -exec cp -v {} /tmp/ICAClient-rhel.rpm \;
MOUNTPOINTS="/dev /proc /run /sys /tmp"
for i in ${MOUNTPOINTS}; do
	mount -B ${i} ${MNT_ROOT}${i};
done;
chroot ${MNT_ROOT} << EOF
	dnf install -y /tmp/ICAClient-rhel.rpm
	rm -rf /tmp/ICAClient-rhel.rpm
EOF
for i in ${MOUNTPOINTS}; do
	umount ${MNT_ROOT}${i};
done;
