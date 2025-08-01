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
#mkdir -p /home/$name/.local/share/cinnamon/extensions

#cp -r /cinnamon-configs/cinnamon-stuff/extensions/* /home/$name/.local/share/cinnamon/extensions

#cp -r /cinnamon-configs/cinnamon-stuff/nemo/* /home/$name/.config/nemo

cp -r /cinnamon-configs/cinnamon-stuff/.config/* /home/$name/.config/

mkdir /home/$name/.config/autostart

cp -r /cinnamon-configs/dd.desktop /home/$name/.config/autostart

chown -R $name:$name /home/$name/.config
chown -R $name:$name /middle.png
#mv /middle.png /home/$USER

cp -r /cinnamon-configs/.bashrc /home/$name/.bashrc
cp -r /cinnamon-configs/.bashrc /root
cp -r /cinnamon-configs/AcreetionOS.txt /root
cp -r /cinnamon-configs/AcreetionOS.txt /home/$name/AcreetionOS.txt

mv /resolv.conf /etc/resolv.conf
chattr +i /etc/resolv.conf
chattr +i /etc/os-release

# create python fix!

#mkdir -p /usr/lib/python3.13/site-packages/six
#touch /usr/lib/python3.13/site-packages/six/__init__.py
#cp /usr/lib/python3.12/site-packages/six.py /usr/lib/python3.13/site-packages/six/six.py

# cp /archiso.conf /etc/mkinitcpio.conf.d/archiso.conf

# mkdir /home/$name/.local/share/cinnamon

# cp -r /cinnamon-configs/cinnamon-stuff/extensions /home/$name/.local/share/cinnamon/

cp /cinnamon-configs/AcreetionOS.txt /home/$name/

mkdir -p /usr/share/backgrounds
cp -r /backgrounds /usr/share/backgrounds
rm -rf /backgrounds

#chsh -s /bin/bash root

echo "Defaults pwfeedback" | sudo EDITOR='tee -a' visudo >/dev/null 2>&1

#cp -r /cinnamon-configs/spices/* /home/$name/.config/cinnamon/spices/
cp /etc/pacman2.conf pacman.conf
cp /mkinitcpio/mkinitcpio.conf /etc/mkinitcpio.conf
cp /mkinitcpio/archiso.conf /etc/mkinitcpio.conf.d
cp /cinnamon-configs/.nanorc /home/$name/.nanorc

rm -rf /mkinitcpio
rm -rf cinnamon-configs


