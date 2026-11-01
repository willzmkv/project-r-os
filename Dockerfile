FROM archlinux:latest

# Disable signature checks for Docker build environment
RUN sed -i 's/SigLevel    = Required DatabaseOptional/SigLevel = Never/' /etc/pacman.conf && \
    sed -i 's/LocalFileSigLevel = Optional/LocalFileSigLevel = Never/' /etc/pacman.conf && \
    sed -i 's/SigLevel = Required DatabaseOptional/SigLevel = Never/g' /etc/pacman.conf

# Add CachyOS repos
RUN printf '\n[cachyos]\nServer = https://mirror.cachyos.org/repo/$arch/$repo\n' \
    >> /etc/pacman.conf

# Full system upgrade + CachyOS mirrorlist
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm cachyos-mirrorlist

# Switch to mirrorlist-based includes
RUN sed -i 's|Server = https://mirror.cachyos.org/repo/\$arch/cachyos$|Include = /etc/pacman.d/cachyos-mirrorlist|' /etc/pacman.conf

# Install ISO build tools + compilation deps for AUR packages
RUN pacman -S --noconfirm \
        archiso base-devel git bats \
        squashfs-tools erofs-utils \
        dosfstools mtools libisoburn \
        grub efibootmgr syslinux sudo \
        clang lld llvm ninja patchelf \
        cmake extra-cmake-modules qt6-tools qt6-base qt6-svg \
        vulkan-headers kddockwidgets \
        alsa-lib jack2 libpulse sndio speexdsp \
        sdl2 sdl3 libpng libwebp libxi libxrandr \
        shaderc p7zip \
        bluez-libs curl ffmpeg freetype2 gettext \
        harfbuzz icu libgit2 poppler pugixml \
        libxkbcommon dbus-glib && \
    pacman -Scc --noconfirm

# makepkg refuses root — create build user
RUN useradd -m -G wheel builder && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/wheel

# ── Layer cache optimisation ───────────────────────────────────────────────
# Copy ONLY the PKGBUILD repo first so this layer is re-used when only
# the rest of the project changes (test files, profiledef, etc.).
WORKDIR /aur-build
COPY --chown=builder:builder project-r-repo/ /aur-build/

# Expose the local AUR repo so makepkg -s can install inter-package deps
# and give builder ownership of the workdir so it can create repo/
RUN printf '\n[project-r-local]\nSigLevel = Never\nServer = file:///aur-build/repo\n' >> /etc/pacman.conf && \
    chown builder:builder /aur-build

# Pre-build ALL packages (pr-* stubs + AUR) as a cached Docker image layer.
# Subsequent `docker build` runs only rebuild this layer when PKGBUILDs change.
USER builder
RUN make

# ── Full project ───────────────────────────────────────────────────────────
USER root
WORKDIR /project-r-os
COPY . .
RUN chown -R builder:builder /project-r-os

USER builder

CMD ["bash", "docker-build.sh"]
