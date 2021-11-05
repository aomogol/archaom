#!/usr/bin/env bash
#(
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
if ! source test.conf; then
	read -p "Kullanıcı adı giriniz:" username
#echo "username=$username" >> ${HOME}/archaom/install.conf
echo "username=$username" >> test.conf
fi

if [ $(whoami) = "root"  ];
then
    echo $whoami
    echo "kullanıcı"
    #useradd -m -G wheel,libvirt -s /bin/bash $username 
	#useradd -m -G wheel -s /bin/bash $username 
	#passwd $username
	#cp -R /root/archaom /home/$username/
    #chown -R $username: /home/$username/archaom
	read -p "Makine adı giriniz:" nameofmachine
	echo $nameofmachine > test.conf
else
	echo "AUR paketlerinin yüklenmesi için sistem hazır"
fi