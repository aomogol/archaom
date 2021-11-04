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
```
    loadkeys trq    
```
komutunu çalıştırın)
```
pacman -Sy git
git clone https://github.com/aomogol/archaom
cd archaom
./archtitus.sh
```

### Sistem İçeriği


## Sorunlar ve Çözümler

__[Arch Linux Installation Guide](https://github.com/rickellis/Arch-Linux-Install-Guide)__

###  Wifi çalışmıyorsa

#1:`iwctl` komutuu çalıştırın.

#2: `device list` komutunu çalıştırın , cihazınızın adını bulun.

#3: `station [device name] scan` komutunu çalıştırın.

#4: `station [device name] get-networks` komutunu çalıştırın.

#5: Bağlanmak istediğiniz ağı bulun, `station [device name] connect [network name]` komutunu çalıştırın., şifrenizi girin ve `exit` ile çıkış yapın. İnternet bağlantısını test etmek için `ping google.com`komutunu çalıştırın.

## Credits

- Bu paketin orjinali Chris Titus tarafından hazırlanmıştır. https://github.com/christitustech/archtitus 
