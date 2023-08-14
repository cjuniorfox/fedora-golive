#!/bin/bash
. ./environment.sh

mkdir ${MNT_HOME}
mount ${USB_DRIVE}3 ${MNT_HOME}

sudo rsync -axHAWXS --numeric-ids --info=progress2 /home/* ${MNT_HOME}
umount ${MNT_HOME}
rm -rfv ${MNT_HOME}
