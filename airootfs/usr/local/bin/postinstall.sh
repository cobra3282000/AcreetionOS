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

cp /cinnamon-configs/cinnamon-stuff/bin/* /bin/
cp /cinnamon-configs/cinnamon-stuff/usr/bin/* /usr/bin/
cp -r /cinnamon-configs/cinnamon-stuff/usr/share/* /usr/share/

mkdir /home/$name/.config
mkdir /home/$name/.config/nemo

cp -r /cinnamon-configs/cinnamon-stuff/nemo/* /home/$name/.config/nemo

cp -r /cinnamon-configs/cinnamon-stuff/.config/* /home/$name/.config/

mkdir /home/$name/.config/autostart

cp -r /cinnamon-configs/dd.desktop /home/$name/.config/autostart

chown -R $name:$name /home/$name/.config

cp -r /cinnamon-configs/.bashrc /home/$name/.bashrc

#!/bin/bash

# Log function
log() {
    echo "[Postinstall] $1"
}

log "Starting post-installation script..."

# Install necessary packages
log "Installing required packages..."
pacman -Sy --noconfirm grub efibootmgr linux linux-firmware mkinitcpio || log "Package installation failed"

# Mount necessary filesystems
log "Mounting virtual filesystems..."
mount -t proc proc /proc || log "Failed to mount proc"
mount -t sysfs sys /sys || log "Failed to mount sysfs"
mount -t devtmpfs udev /dev || log "Failed to mount devtmpfs"
mount -t efivarfs efivarfs /sys/firmware/efi/efivars 2>/dev/null || log "EFI vars mount failed (might be normal for BIOS)"

# Install GRUB
log "Installing GRUB bootloader..."
if [ -d /sys/firmware/efi ]; then
    log "Detected UEFI system"
    mkdir -p /boot/efi
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck || log "UEFI GRUB install failed"
else
    log "Detected BIOS system"
    grub-install --target=i386-pc --recheck /dev/sda || log "BIOS GRUB install failed"
fi

# Configure mkinitcpio
log "Configuring mkinitcpio..."
sed -i 's/MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/' /etc/mkinitcpio.conf

# Generate initramfs
log "Generating initramfs..."
mkinitcpio -P linux || log "Initramfs generation failed"

# Generate GRUB config
log "Generating GRUB configuration..."
grub-mkconfig -o /boot/grub/grub.cfg || log "GRUB config generation failed"

# Verify installations
log "Verifying installation..."
if [ ! -f /boot/initramfs-linux.img ]; then
    log "ERROR: Missing initramfs"
fi

if [ ! -f /boot/vmlinuz-linux ]; then
    log "ERROR: Missing kernel"
fi

if [ ! -f /boot/grub/grub.cfg ]; then
    log "ERROR: Missing GRUB config"
fi

# Final check
if [ -f /boot/initramfs-linux.img ] && [ -f /boot/vmlinuz-linux ] && [ -f /boot/grub/grub.cfg ]; then
    log "Post-installation completed successfully"
else
    log "Post-installation completed with errors"
    exit 1
fi

exit 0

