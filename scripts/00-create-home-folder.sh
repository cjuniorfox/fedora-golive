#!/bin/bash
set -x
. ./environment.sh
echo "Creating home folder"
MOUNTPOINTS="/dev /proc /run /sys /tmp"
for i in ${MOUNTPOINTS}; do
	mount -B ${i} ${MNT_ROOT}${i};
done;
chroot ${MNT_ROOT} << EOF
for user in $(awk -F: '$3 >= 1000 && $3 < 2000 {print $1}' /etc/passwd); do 
mkhomedir_helper \${user}
su - \${user} << HEREDOC
xdg-user-dirs-update
xdg-user-dirs-gtk-update
HEREDOC
done
EOF
for i in ${MOUNTPOINTS}; do
	umount ${MNT_ROOT}${i};
done;
