# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AcreetionOS is an Arch-based Linux distribution project focused on providing a stable, user-friendly experience. This repository contains the ISO build system using archiso tools to create bootable installation media.

## Build Commands

### Build ISO
```bash
./build.sh
```
This is the main build command that:
1. Runs `./refresh.sh -j` for parallel package updates
2. Runs `./mkarchiso.sh` to create the ISO
3. Cleans up work directory and cache files

### Direct ISO Build
```bash
./mkarchiso.sh
```
Uses mkarchiso with specific AcreetionOS configuration to build ISO in `../ISO` directory.

### Clean Build Environment
```bash
sudo rm -rf ./work
sudo rm /var/cache/pacman/pkg/*
```

## Project Architecture

### Core Configuration Files

- **profiledef.sh**: Main archiso profile defining ISO metadata, bootmodes, compression settings, and file permissions
- **packages.x86_64**: Package list for the distribution (250+ packages including Cinnamon DE, system tools, drivers)
- **pacman.conf**: Custom pacman configuration with AcreetionOS repositories and parallel downloads
- **bootstrap_packages.x86_64**: Bootstrap packages for initial system

### Directory Structure

- **airootfs/**: Root filesystem overlay containing custom configurations, themes, and user files
- **efiboot/**: EFI boot configuration
- **grub/**: GRUB bootloader configuration  
- **syslinux/**: SYSLINUX bootloader configuration

### Key Features

- Cinnamon desktop environment as default
- Custom AcreetionOS branding and themes
- Calamares installer integration
- Support for both BIOS and UEFI boot modes
- Comprehensive hardware driver support (AMD, Intel, Nouveau)
- Development tools (Python, Rust, Node.js, Git)

## Package Management

The distribution uses a custom pacman configuration with:
- Parallel downloads (25 concurrent)
- File overwrite permissions enabled
- Custom package ignores (v4l2loopback-dkms)
- Mixed signature verification levels

## Boot Configuration

Supports multiple boot modes:
- BIOS: syslinux (MBR and El Torito)
- UEFI: systemd-boot (IA32 and x64, ESP and El Torito)

## File System

- Uses squashfs compression with XZ algorithm
- Custom file permissions defined in profiledef.sh for security
- Bootstrap tarball uses zstd compression