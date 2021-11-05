#!/usr/bin/env bash
#(
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
if ! source test.conf; then
	echo " ############################################################"
	echo " 	Kullanıcı adının belirlenmesi"
	echo " ############################################################"
	read -p "Kullanıcı adı giriniz:" username
	echo "username=$username" >> test.conf
fi
if [ ! $(whoami) = "root"  ];
then
    #useradd -m -G wheel,libvirt -s /bin/bash $username 
	#useradd -m -G wheel -s /bin/bash $username 
	#passwd $username
	#cp -R /root/archaom /home/$username/
    #chown -R $username: /home/$username/archaom
    if  grep -q "^nameofmachine=" test.conf; then

	echo " ############################################################"
	echo " 	Makine adının belirlenmesi"
	echo " ############################################################"
	read -p "Makine adı giriniz:" nameofmachine
	#echo $nameofmachine > /etc/hostname
	echo "nameofmachine=$nameofmachine" >> test.conf
	echo " Girilen makine ismi = $nameofmachine"
    else  
        echo "makine ismi var" 
    fi
else
	echo "AUR paketlerinin yüklenmesi için sistem hazır"
fi

if ! grep -q "^libvirt:" /etc/group; then
		groupadd libvirt
		echo "libvirt group oluşturuldu"
	else
		echo "Grup zaten var"
	fi