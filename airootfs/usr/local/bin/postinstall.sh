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

log "Starting complete boot setup..."

# Install necessary packages
log "Installing required packages..."
pacman -Sy --noconfirm \
    grub \
    efibootmgr \
    linux \
    linux-firmware \
    mkinitcpio \
    os-prober || log "Package installation failed"

# Create necessary directories
log "Creating boot directories..."
mkdir -p /boot || log "Failed to create /boot"
mkdir -p /boot/grub || log "Failed to create /boot/grub"
mkdir -p /boot/efi || log "Failed to create /boot/efi"

# Mount necessary filesystems
log "Mounting virtual filesystems..."
mount -t proc proc /proc || log "Failed to mount proc"
mount -t sysfs sys /sys || log "Failed to mount sysfs"
mount -t devtmpfs udev /dev || log "Failed to mount devtmpfs"
mount -t efivarfs efivarfs /sys/firmware/efi/efivars 2>/dev/null || log "EFI vars mount failed (might be normal for BIOS)"

# Create initial mkinitcpio config
log "Creating mkinitcpio configuration..."
cat > /etc/mkinitcpio.conf << EOF
MODULES=(ext4)
BINARIES=()
FILES=()
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)
EOF

# Create initial GRUB config
log "Creating GRUB configuration..."
cat > /etc/default/grub << EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="AcreetionOS"
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX=""
GRUB_PRELOAD_MODULES="part_gpt part_msdos"
GRUB_DISABLE_OS_PROBER=false
GRUB_DISABLE_SUBMENU=y
GRUB_TERMINAL_OUTPUT="console"
EOF

# Install GRUB
log "Installing GRUB bootloader..."
if [ -d /sys/firmware/efi ]; then
    log "Detected UEFI system"
    # Create EFI directory structure
    mkdir -p /boot/efi/EFI/GRUB || log "Failed to create EFI directories"
    
    # Install GRUB for UEFI
    grub-install \
        --target=x86_64-efi \
        --efi-directory=/boot/efi \
        --bootloader-id=GRUB \
        --recheck \
        --removable || log "UEFI GRUB install failed"
    
    # Backup EFI files
    cp -r /boot/efi/EFI/GRUB /boot/efi/EFI/BOOT
    cp /boot/efi/EFI/GRUB/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
else
    log "Detected BIOS system"
    # Install GRUB for BIOS
    grub-install \
        --target=i386-pc \
        --recheck \
        /dev/sda || log "BIOS GRUB install failed"
fi

# Generate initramfs
log "Generating initramfs..."
mkinitcpio -P linux || log "Initramfs generation failed"

# Generate GRUB config
log "Generating GRUB configuration..."
grub-mkconfig -o /boot/grub/grub.cfg || log "GRUB config generation failed"

# Verify all required files exist
log "Verifying boot files..."

CHECK_FILES=(
    "/boot/initramfs-linux.img"
    "/boot/vmlinuz-linux"
    "/boot/grub/grub.cfg"
    "/etc/default/grub"
    "/etc/mkinitcpio.conf"
)

for file in "${CHECK_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        log "ERROR: Missing $file"
    else
        log "Verified: $file exists"
    fi
done

# Additional UEFI checks
if [ -d /sys/firmware/efi ]; then
    EFI_FILES=(
        "/boot/efi/EFI/GRUB/grubx64.efi"
        "/boot/efi/EFI/BOOT/BOOTX64.EFI"
    )
    
    for file in "${EFI_FILES[@]}"; do
        if [ ! -f "$file" ]; then
            log "ERROR: Missing $file"
        else
            log "Verified: $file exists"
        fi
    done
    
    # Show EFI boot entries
    log "EFI boot entries:"
    efibootmgr -v
fi

# Show boot directory contents
log "Boot directory contents:"
ls -la /boot
log "EFI directory contents (if applicable):"
ls -la /boot/efi/EFI 2>/dev/null

# Verify permissions
log "Setting correct permissions..."
chmod 700 /boot
chmod 700 /boot/efi 2>/dev/null
chmod 600 /boot/initramfs-linux.img

# Final verification
ERRORS=0
for file in "${CHECK_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        ERRORS=$((ERRORS+1))
    fi
done

if [ $ERRORS -eq 0 ]; then
    log "Post-installation completed successfully"
    exit 0
else
    log "Post-installation completed with $ERRORS errors"
    exit 1
fi
