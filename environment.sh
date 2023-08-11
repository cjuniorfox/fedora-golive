#!/bin/bash

USB_DRIVE="/dev/loop0p"

EFI_SIZE="512M"        # EFI partition size
LIVE_SIZE="8G"         # Fedora Live partition size
HOME_SIZE="100%"       # Use the remaining space for /home

LABEL_ROOT="golive-root"
LABEL_HOME="golive-home"

MNT_HOME="/tmp/__home"
MNT_ROOT="/tmp/__root"
MNT_EFI="/tmp/__efi"
