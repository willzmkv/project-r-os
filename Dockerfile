# CachyOS base — repos, keyring, and BORE kernel packages pre-configured
FROM ghcr.io/cachyos/cachyos:latest

# Install build tools
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        archiso \
        base-devel \
        git \
        bats \
        squashfs-tools \
        erofs-utils \
        dosfstools \
        mtools \
        libisoburn \
        grub \
        efibootmgr \
        syslinux \
        sudo && \
    pacman -Scc --noconfirm

# makepkg refuses to run as root — create build user
RUN useradd -m -G wheel builder && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/wheel

WORKDIR /project-r-os
COPY . .
RUN chown -R builder:builder /project-r-os

USER builder

# Entry: build repo stubs, run package tests, build ISO
CMD ["bash", "docker-build.sh"]
