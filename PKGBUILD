# Maintainer: Your Name <your.email@example.com>

pkgbase=linux-custom-m4200
pkgver=6.12.13
pkgrel=1
_srcname=.
_kernelname=${pkgbase#linux}
arch=('x86_64')
url="https://www.kernel.org/"
license=('GPL2')
makedepends=('kmod')
options=('!strip')

source=()
sha256sums=()

pkgname=("$pkgbase" "$pkgbase-headers")

package_linux-custom-m4200() {
  pkgdesc="The Linux kernel and modules with NVIDIA Quadro M4200 support (LTS 6.12 series)"
  depends=('coreutils' 'linux-firmware' 'kmod' 'mkinitcpio>=0.7')
  optdepends=('crda: to set the correct wireless channels of your country'
              'nvidia-470xx-dkms: NVIDIA drivers for Quadro M4200')
  provides=("linux=${pkgver}")
  conflicts=('linux')
  install=linux.install

  cd "${_srcname}"
  
  # Hardcode the kernel version since we know it
  local kernver="${pkgver}-${pkgrel}-${pkgbase#linux}"
  echo "Using kernel version: ${kernver}"
  
  local modulesdir="${pkgdir}/usr/lib/modules/${kernver}"
  mkdir -p "${modulesdir}"
  
  echo "Installing boot image..."
  # Directly find the kernel image using find
  local kernel_image=$(find . -name "bzImage" | grep -v "\.o\." | head -n1)
  
  if [ -z "${kernel_image}" ]; then
    echo "Searching for vmlinux..."
    kernel_image=$(find . -name "vmlinux" | grep -v "\.o\." | head -n1)
  fi
  
  if [ -z "${kernel_image}" ]; then
    echo "ERROR: Could not find kernel image! Please specify the path manually in the PKGBUILD."
    # Direct manual specification - edit if needed
    kernel_image="./arch/x86/boot/bzImage"
    # Check if this file exists
    if [ ! -f "${kernel_image}" ]; then
      echo "The manually specified path doesn't exist either."
      exit 1
    fi
  fi
  
  echo "Found kernel image at: ${kernel_image}"
  install -Dm644 "${kernel_image}" "${modulesdir}/vmlinuz"
  
  # Used by mkinitcpio to name the kernel
  echo "${pkgbase}" | install -Dm644 /dev/stdin "${modulesdir}/pkgbase"
  
  echo "Installing modules..."
  if [ -d "./lib/modules/${pkgver}" ]; then
    # Copy modules if already built
    mkdir -p "${pkgdir}/usr/lib/modules"
    cp -a "./lib/modules/${pkgver}" "${pkgdir}/usr/lib/modules/"
    # Rename directory if needed
    if [ "${pkgver}" != "${kernver}" ]; then
      mv "${pkgdir}/usr/lib/modules/${pkgver}" "${modulesdir}"
    fi
  elif [ -d "./modules" ]; then
    # Copy from ./modules if available
    mkdir -p "${pkgdir}/usr/lib/modules"
    cp -a "./modules" "${modulesdir}"
  else
    # Fallback to make install if needed
    make INSTALL_MOD_PATH="${pkgdir}/usr" INSTALL_MOD_STRIP=1 modules_install
  fi
  
  # remove build and source links
  rm -f "${modulesdir}"/{source,build}
  
  # Create a symlink from /boot to the kernel
  mkdir -p "${pkgdir}/boot"
  ln -sf "/usr/lib/modules/${kernver}/vmlinuz" "${pkgdir}/boot/vmlinuz-${pkgbase}"
}

package_linux-custom-m4200-headers() {
  pkgdesc="Header files and scripts for building modules for linux-custom-m4200"
  provides=("linux-headers=${pkgver}")
  
  cd "${_srcname}"
  
  # Hardcode the kernel version
  local kernver="${pkgver}-${pkgrel}-${pkgbase#linux}"
  echo "Using kernel version: ${kernver}"
  
  local builddir="${pkgdir}/usr/lib/modules/${kernver}/build"
  mkdir -p "${builddir}"
  
  echo "Installing build files..."
  
  # Function to safely install a file if it exists
  safe_install() {
    local src="$1"
    local dst="$2"
    local mode="$3"
    
    if [ -f "${src}" ]; then
      install -Dm${mode} "${src}" "${dst}"
      return 0
    else
      echo "Warning: File not found: ${src}"
      return 1
    fi
  }
  
  # Install key files
  for file in .config Makefile Module.symvers System.map vmlinux; do
    safe_install "${file}" "${builddir}/${file}" 644
  done
  
  # Install version info
  echo "${kernver}" > version
  safe_install "version" "${builddir}/version" 644
  
  # Create directories
  mkdir -p "${builddir}"/{kernel,arch/x86}
  
  # Install kernel Makefile
  safe_install "kernel/Makefile" "${builddir}/kernel/Makefile" 644
  
  # Install arch Makefile
  safe_install "arch/x86/Makefile" "${builddir}/arch/x86/Makefile" 644
  
  # Copy scripts
  if [ -d "scripts" ]; then
    cp -a scripts "${builddir}/"
  else
    echo "Warning: scripts directory not found"
  fi
  
  # Copy include
  if [ -d "include" ]; then
    cp -a include "${builddir}/"
  else
    echo "Warning: include directory not found"
  fi
  
  # Copy arch include
  if [ -d "arch/x86/include" ]; then
    mkdir -p "${builddir}/arch/x86"
    cp -a arch/x86/include "${builddir}/arch/x86/"
  else
    echo "Warning: arch/x86/include directory not found"
  fi
  
  # Install KConfig files
  find . -name 'Kconfig*' -exec install -Dm644 {} "${builddir}/{}" \; 2>/dev/null || echo "Warning: No Kconfig files found"
  
  # Install objtool
  if [ -f "tools/objtool/objtool" ]; then
    mkdir -p "${builddir}/tools/objtool"
    install -m755 tools/objtool/objtool "${builddir}/tools/objtool/"
  fi
  
  # Create symlink for kernel sources
  mkdir -p "${pkgdir}/usr/src"
  ln -sr "${builddir}" "${pkgdir}/usr/src/${pkgbase}"
}
