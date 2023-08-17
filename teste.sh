#!/bin/bash
. ./environment.sh

mkdir -p {root/LiveOS,${MNT_ROOT}}
mount -o loop root/LiveOS/rootfs.img ${MNT_ROOT}/

home_dir=/home
#for user in $(ls $home_dir); do
#	if [ -d "$home_dir/$user" ]; then
#		mkdir -p "${MNT_ROOT}/home/$user"
#		cp -Rv /etc/skel/.* "${MNT_ROOT}/home/$user/"
#		chown -R $user:$user "${MNT_ROOT}/home/$user"
#		chmod -R 700 "${MNT_ROOT}/home/$user"
#	fi
#done;

run-parts ./scripts/

umount ${MNT_ROOT}/
rm -rfv ${MNT_ROOT}/
