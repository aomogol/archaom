#!/usr/bin/env bash
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
#
# determine processor type and install microcode
# 
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		echo "Intel microcode kuruluyor"
		pacman -S --noconfirm --neede intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		echo "AMD microcode kuruluyor"
		pacman -S --noconfirm --needed amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	
