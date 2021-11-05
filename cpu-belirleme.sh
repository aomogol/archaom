#!/usr/bin/env bash
#
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		echo "Installing Intel microcode"
		#pacman -S --noconfirm intel-ucode
		#proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		echo "Installing AMD microcode"
		#pacman -S --noconfirm amd-ucode
		#proc_ucode=amd-ucode.img
		;;
esac	
