FROM archlinux:latest

# Disable signature checks for Docker build environment
# (not needed for production — ISO itself verifies packages at build time)
RUN sed -i 's/SigLevel    = Required DatabaseOptional/SigLevel = Never/' /etc/pacman.conf && \
    sed -i 's/LocalFileSigLevel = Optional/LocalFileSigLevel = Never/' /etc/pacman.conf && \
    sed -i 's/SigLevel = Required DatabaseOptional/SigLevel = Never/g' /etc/pacman.conf

# Add CachyOS repos (no keyring needed since SigLevel = Never)
RUN printf '\n[cachyos]\nServer = https://mirror.cachyos.org/repo/$arch/$repo\n\n[cachyos-extra]\nServer = https://mirror.cachyos.org/repo/$arch/$repo\n' \
    >> /etc/pacman.conf

# Full system upgrade + CachyOS mirrorlist
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm cachyos-mirrorlist

# Switch to mirrorlist-based includes
RUN sed -i 's|Server = https://mirror.cachyos.org/repo/\$arch/cachyos$|Include = /etc/pacman.d/cachyos-mirrorlist|' /etc/pacman.conf && \
    sed -i 's|Server = https://mirror.cachyos.org/repo/\$arch/cachyos-extra$|Include = /etc/pacman.d/cachyos-mirrorlist|' /etc/pacman.conf

# Install build tools
RUN pacman -S --noconfirm \
        archiso base-devel git bats \
        squashfs-tools erofs-utils \
        dosfstools mtools libisoburn \
        grub efibootmgr syslinux sudo && \
    pacman -Scc --noconfirm

# makepkg refuses root — create build user
RUN useradd -m -G wheel builder && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/wheel

WORKDIR /project-r-os
COPY . .
RUN chown -R builder:builder /project-r-os

USER builder

CMD ["bash", "docker-build.sh"]
