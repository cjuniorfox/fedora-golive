#!/bin/bash
. ./environment.sh
echo "Making home work"
home_dir="/home"
dest_dir="${MNT_ROOT}/home"
for user in $(ls $home_dir); do
	for i in hypr rofi waybar; do
		config="$user/.config/$i"
		if [ -d "${home_dir}/${config}" ]; then
			mkdir -p "${dest_dir}/${config}"
			cp -Rv ${home_dir}/${config}/* ${dest_dir}/${config}/
		fi
	done;
	chown -R $user:$user "${dest_dir}"
	chmod -R 700 "${dest_dir}"
done;
