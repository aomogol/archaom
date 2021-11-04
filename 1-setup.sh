#!/usr/bin/env bash
(
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "---------------------------------------------------------------"
echo "Optimum indirme performansı için Mirrorlist düzenlemesi        "
echo "---------------------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.yedek

nc=$(grep -c ^processor /proc/cpuinfo)
echo "Sisteminizde " $nc" core var."
echo "-------------------------------------------------"
echo "makeflags "$nc" core için düzenleniyor."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g' /etc/makepkg.conf
echo " Sıkıştırma ayarları "$nc" core için ayarlanıyor."
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g' /etc/makepkg.conf
fi
echo "-------------------------------------------------------"
echo "       Dil ayarları (TR) ve Lokalizasyon ayarları   "
echo "-------------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#tr_TR.UTF-8 UTF-8/tr_TR.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#tr_TR ISO-8859-9/tr_TR ISO-8859-9/' /etc/locale.gen

locale-gen
timedatectl --no-ask-password set-timezone Europe/Istanbul
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="tr_TR.UTF-8" LC_TIME="tr_TR.UTF-8"

# keymaps tanımı
localectl --no-ask-password set-keymap trq

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

# parallel download ve renkler
sed -i 's/^#Para/Para/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

echo -e "\n Temel sistem uygulamalarının kurulumu \n"

PKGS=(
'mesa' # Essential Xorg First
'xorg'
'xorg-server'
'xorg-apps'
'xorg-drivers'
'xorg-xkill'
'xorg-xinit'
'xterm'
'plasma-desktop' # KDE Load second
'alsa-plugins' # audio plugins
'alsa-utils' # audio utils
'ark' # compression
'audiocd-kio' 
'autoconf' # build
'automake' # build
'base'
'bash-completion'
'bind'
'binutils'
'bison'
'bluedevil'
'bluez'
'bluez-libs'
'bluez-utils'
'breeze'
'breeze-gtk'
'bridge-utils'
'btrfs-progs'
# 'celluloid' # video players
# 'cmatrix'
# 'code' # Visual Studio code
'cronie'
'cups'
'dialog'
'discover'
'dolphin'
'dosfstools'
'dtc'
'efibootmgr' # EFI boot
'egl-wayland'
'exfat-utils'
'extra-cmake-modules'
'filelight'
'flex'
'fuse2'
'fuse3'
'fuseiso'
# 'gamemode'
'gcc'
# 'gimp' # Photo editing
'git'
'gparted' # partition management
'gptfdisk'
'grub'
'grub-customizer'
'gst-libav'
'gst-plugins-good'
'gst-plugins-ugly'
'gwenview'
'haveged'
'htop'
'iptables-nft'
# 'jdk-openjdk' # Java 17
'kate'
'kcodecs'
'kcoreaddons'
'kde-plasma-addons'
'kinfocenter'
'kscreen'
'kvantum-qt5'
'kde-gtk-config'
'kitty'
'konsole'
'kscreen'
'layer-shell-qt'
'libdvdcss'
'libnewt'
'libtool'
'linux'
'linux-firmware'
'linux-headers'
'lsof'
# 'lutris'
'lzop'
'm4'
'make'
'milou'
'nano'
'neofetch'
'networkmanager'
'ntfs-3g'
'ntp'
'okular'
'openbsd-netcat'
'openssh'
'os-prober'
'oxygen'
'p7zip'
'pacman-contrib'
'partitionmanager'
'patch'
'picom'
'pkgconf'
'plasma-nm'
'powerdevil'
'powerline-fonts'
'print-manager'
'pulseaudio'
'pulseaudio-alsa'
'pulseaudio-bluetooth'
'python-notify2'
'python-psutil'
'python-pyqt5'
'python-pip'
'qemu'
'rsync'
'sddm'
'sddm-kcm'
'snapper'
'spectacle'
# 'steam'
'sudo'
'swtpm'
# 'synergy'
'systemsettings'
'terminus-font'
'traceroute'
'ufw'
'unrar'
'unzip'
'usbutils'
'vim'
'virt-manager'
'virt-viewer'
'wget'
'which'
# 'wine-gecko'
# 'wine-mono'
# 'winetricks'
'xdg-desktop-portal-kde'
'xdg-user-dirs'
'zeroconf-ioslave'
'zip'
'zsh'
'zsh-syntax-highlighting'
'zsh-autosuggestions'
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

#
# determine processor type and install microcode
# 
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Intel microcode kuruluyor"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "AMD microcode kuruluyor"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -e "\nTamamlandı!\n"
if ! source install.conf; then
	read -p "Kullanıcı adı giriniz:" username
echo "username=$username" >> ${HOME}/archaom/install.conf
fi
if [ $(whoami) = "root"  ];
then
    #useradd -m -G wheel,libvirt -s /bin/bash $username 
	useradd -m -G wheel -s /bin/bash $username 
	passwd $username
	cp -R /root/archaom /home/$username/
    chown -R $username: /home/$username/archaom
	read -p "Makine adı giriniz:" nameofmachine
	echo $nameofmachine > /etc/hostname
else
	echo "AUR paketlerinin yüklenmesi için sistem hazır"
fi

) 2>&1 | tee 1-setuplog.txt
