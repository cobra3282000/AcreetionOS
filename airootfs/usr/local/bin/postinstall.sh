#!/bin/bash -e
#
##############################################################################
#
#  PostInstall is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your discretion) any later version.
#
#  PostInstall is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
##############################################################################

 name=$(ls -1 /home)
 REAL_NAME=/home/$name

# genfstab -U / > /etc/fstab

#cp /cinnamon-configs/cinnamon-stuff/bin/* /bin/
#cp /cinnamon-configs/cinnamon-stuff/usr/bin/* /usr/bin/
#cp -r /cinnamon-configs/cinnamon-stuff/usr/share/* /usr/share/

mkdir /home/$name/.config
mkdir /home/$name/.config/nemo

#cp -r /cinnamon-configs/cinnamon-stuff/nemo/* /home/$name/.config/nemo

cp -r /cinnamon-configs/cinnamon-stuff/.config/* /home/$name/.config/

mkdir /home/$name/.config/autostart

cp -r /cinnamon-configs/dd.desktop /home/$name/.config/autostart

chown -R $name:$name /home/$name/.config

cp -r /cinnamon-configs/.bashrc /home/$name/.bashrc
cp -r /cinnamon-configs/.bashrc /root

mv /resolv.conf /etc/resolv.conf
chattr +i /etc/resolv.conf

cp /archiso.conf /etc/mkinitcpio.conf.d/archiso.conf


