#!/usr/bin/env bash
#(
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "-------------------------------------------------------"
echo "Optimum indirme performansı için Mirrorlist düzenlemesi"
echo "-------------------------------------------------------"
iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -S --noconfirm pacman-contrib 
# pacman -S --noconfirm terminus-font
#setfont ter-v22b
sed -i 's/^#Para/Para/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf

pacman -S --noconfirm reflector rsync grub
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

echo -e "-------------------------------------------------------------------------"
echo -e "-------------------------------------------------------------------------"
echo -e "- $iso için en hızlı indirme noktalarının ayarlanması.                   "
echo -e "-------------------------------------------------------------------------"
echo -e "-------------------------------------------------------------------------"
#reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
reflector -a 48 -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
mkdir /mnt

echo -e "-------------------------------------------------------------------------"
echo -e "\n Gerekli paketlerin yüklenmesi...\n$HR"
pacman -S --noconfirm gptfdisk btrfs-progs

echo "-------------------------------------------------"
echo "--- Yükleme yapılacak diskin formatlanması-------"
echo "-------------------------------------------------"
lsblk
echo "Yüklemenin yapılacağı disk : (örnek /dev/sda)"
read DISK
echo "SEÇTİĞİNİZ DİSK FORMATLANACAK ve TÜM BİLGİLER SİLİNECEKTİR"
echo "YEDEKLEME İŞLEMİNİZİ YAPTIĞINIZDAN EMİN OLUNUZ."
read -p "devam etmek istediğinizden emin misiniz? (E/H Y/N):" formatdisk
case $formatdisk in

y|Y|yes|Yes|YES|E|e|evet|Evet|EVET)
echo "--------------------------------------"
echo -e "\n Disk Formatlanıyor ...\n$HR"
echo "--------------------------------------"

# disk hazırlıpı
sgdisk -Z ${DISK} # tüm disk temizleniyor
sgdisk -a 2048 -o ${DISK} # yeni GPT disk tanımlanıyor

# bölümleri yaratma
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${DISK} # partition 1 (BIOS Boot Partition)
sgdisk -n 2::+200M --typecode=2:ef00 --change-name=2:'EFIBOOT' ${DISK} # partition 2 (UEFI Boot Partition)
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' ${DISK} # partition 3 (Root), 
if [[ ! -d "/sys/firmware/efi" ]]; then
    sgdisk -A 1:set:2 ${DISK}
fi

#Disk bölümleri yapılandırılıyor
echo -e "\n Disk bölümleri yapılandırılıyor...\n$HR"
if [[ ${DISK} =~ "nvme" ]]; then
mkfs.vfat -F32 -n "EFIBOOT" "${DISK}p2"
mkfs.btrfs -L "ROOT" "${DISK}p3" -f
mount -t btrfs "${DISK}p3" /mnt
else
mkfs.vfat -F32 -n "EFIBOOT" "${DISK}2"
mkfs.btrfs -L "ROOT" "${DISK}3" -f
mount -t btrfs "${DISK}3" /mnt
fi
ls /mnt | xargs btrfs subvolume delete
btrfs subvolume create /mnt/@
umount /mnt
;;
*)
echo "Yeniden başlatılacak 3 ..." && sleep 1
echo "Yeniden başlatılacak 2 ..." && sleep 1
echo "Yeniden başlatılacak 1 ..." && sleep 1
reboot now
;;
esac

# mount target
mount -t btrfs -o subvol=@ -L ROOT /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount -t vfat -L EFIBOOT /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Sürücü mount edilemediği için devam edilemiyor"
    echo "Yeniden başlatılacak 3 ..." && sleep 1
    echo "Yeniden başlatılacak 2 ..." && sleep 1
    echo "Yeniden başlatılacak 1  ..." && sleep 1
    reboot now
fi

echo "--------------------------------------------"
echo "-- Ana bölüme Arch Linux kuruluyor        --"
echo "--------------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware vim nano sudo archlinux-keyring wget libnewt --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp -R ${SCRIPT_DIR} /mnt/root/archaom
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
echo "--------------------------------------"
echo "--GRUB BIOS Bootloader Install&Check--"
echo "--------------------------------------"
if [[ ! -d "/sys/firmware/efi" ]]; then
    grub-install --boot-directory=/mnt/boot ${DISK}
fi
echo "--------------------------------------"
echo "-- Düşük sistem belleği kontrol <8G --"
echo "--------------------------------------"
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -lt 8000000 ]]; then
    #Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
    mkdir /mnt/opt/swap #make a dir that we can apply NOCOW to to make it btrfs-friendly.
    chattr +C /mnt/opt/swap #apply NOCOW, btrfs needs that.
    dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
    chmod 600 /mnt/opt/swap/swapfile #set permissions.
    chown root /mnt/opt/swap/swapfile
    mkswap /mnt/opt/swap/swapfile
    swapon /mnt/opt/swap/swapfile
    #The line below is written to /mnt/ but doesn't contain /mnt/, since it's just / for the sysytem itself.
    echo "/opt/swap/swapfile	none	swap	sw	0	0" >> /mnt/etc/fstab #Add swap to fstab, so it KEEPS working after installation.
fi
echo "-----------------------------------------------------"
echo "--   Sonraki adım için sistem hazır: 1-setup       --"
echo "-----------------------------------------------------"
### log dosyası oluşması için
#) 2>&1 | tee 0-preinstalllog.txt
