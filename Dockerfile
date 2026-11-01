FROM archlinux:latest

# Init keyrings
RUN pacman -Sy --noconfirm archlinux-keyring && \
    pacman-key --populate archlinux

# Add CachyOS signing key
RUN pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com && \
    pacman-key --lsign-key F3B607488DB35A47

# Bootstrap CachyOS repo using direct server URL (before mirrorlist is installed)
RUN printf '\n[cachyos]\nServer = https://mirror.cachyos.org/repo/$arch/$repo\n\n[cachyos-extra]\nServer = https://mirror.cachyos.org/repo/$arch/$repo\n' \
    >> /etc/pacman.conf

# Install CachyOS keyring + mirrorlist, then switch to Include
RUN pacman -Sy --noconfirm cachyos-keyring cachyos-mirrorlist && \
    sed -i 's|Server = https://mirror.cachyos.org/repo/\$arch/cachyos$|Include = /etc/pacman.d/cachyos-mirrorlist|' /etc/pacman.conf && \
    sed -i 's|Server = https://mirror.cachyos.org/repo/\$arch/cachyos-extra$|Include = /etc/pacman.d/cachyos-mirrorlist|' /etc/pacman.conf

# Full system upgrade + install build tools
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        archiso base-devel git bats \
        squashfs-tools erofs-utils \
        dosfstools mtools libisoburn \
        grub efibootmgr syslinux sudo && \
    pacman -Scc --noconfirm

# makepkg won't run as root — create build user
RUN useradd -m -G wheel builder && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/wheel

WORKDIR /project-r-os
COPY . .
RUN chown -R builder:builder /project-r-os

USER builder

CMD ["bash", "docker-build.sh"]
