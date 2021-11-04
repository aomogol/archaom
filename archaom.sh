#!/bin/bash

    bash 0-preinstall.sh
    arch-chroot /mnt /root/archaom/1-setup.sh
    source /mnt/root/archaom/install.conf
    arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/archaom/2-user.sh
    arch-chroot /mnt /root/archaom/3-post-setup.sh