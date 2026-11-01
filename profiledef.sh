#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="project-r"
iso_label="PROJECT_R_$(date +%Y%m)"
iso_publisher="Project-R <https://github.com/willzmkv/project-r-os>"
iso_application="Project-R Arcade OS"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi.grub')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root/customize_airootfs.sh"]="0:0:755"
)
