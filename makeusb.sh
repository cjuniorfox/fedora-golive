#!/bin/bash
set -x 

. ./environment.sh

wipefs -a ${USB_DRIVE}

parted --script ${USB_DRIVE} \
    mklabel gpt \
    mkpart primary fat32 2048s ${EFI_SIZE} \
    name 1 EFI \
    set 1 esp on \
    mkpart primary xfs  ${EFI_SIZE} ${LIVE_SIZE} \
    name 2 ${LABEL_ROOT} \
    mkpart primary xfs ${LIVE_SIZE} 100% \
    name 3 ${LABEL_ROOT}

mkfs.msdos -n EFI -F32 "${USB_DRIVE}1"
mkfs.xfs "${USB_DRIVE}2" -fL ${LABEL_ROOT}
mkfs.xfs "${USB_DRIVE}3" -fL ${LABEL_HOME}
