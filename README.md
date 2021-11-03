Arch Linux kurulumu için pratik ve Türkçe script...

# Arch Linux Kurulum Scripti

Bu çalışma Arch Linux kurulumunu, KDE Plasma masaüstü ortamını, tüm destek paketlerini (ağ, bluetooth, ses, yazıcılar, vb.), tercih ettiğimiz tüm uygulama ve yardımcı programları içeren kurulumları yapar. Burada ki komut dosyaları, tüm sürecin otomatikleştirilmesine izin verir.


---
## Arch ISO edinme 

ArchISO dosyasını <https://archlinux.org/download/> adresinden indirebilirsiniz. 
ISO dosyasını bir USB sürücüye Ventoy veya Etcher gibi bir tool ile aktarın.


## Arch ISO ile boot 

Boot işlemi ile gelen ilk prompt ekranında aşağıdaki komutları çalıştırın:
(Türkçe klavye desteği için 
    loadkeys trq    
                            komutunu çalıştırın)
```
pacman -Sy git
git clone https://github.com/aomogol/archaom
cd archaom
./archtitus.sh
```

### System Description
This is completely automated arch install of the KDE desktop environment on arch using all the packages I use on a daily basis. 

## Troubleshooting

__[Arch Linux Installation Guide](https://github.com/rickellis/Arch-Linux-Install-Guide)__

### No Wifi

#1: Run `iwctl`

#2: Run `device list`, and find your device name.

#3: Run `station [device name] scan`

#4: Run `station [device name] get-networks`

#5: Find your network, and run `station [device name] connect [network name]`, enter your password and run `exit`. You can test if you have internet connection by running `ping google.com`. 

## Credits

- Original packages script was a post install cleanup script called ArchMatic located here: https://github.com/rickellis/ArchMatic
- Thank you to all the folks that helped during the creation from YouTube Chat! Here are all those Livestreams showing the creation: <https://www.youtube.com/watch?v=IkMCtkDIhe8&list=PLc7fktTRMBowNaBTsDHlL6X3P3ViX3tYg>
