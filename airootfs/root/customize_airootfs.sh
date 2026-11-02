#!/usr/bin/env bash
set -euo pipefail

echo "==> [project-r] Running customize_airootfs.sh"

# ── 1. Create arcade user ────────────────────────────────────────────────────
echo "==> Creating arcade user"
useradd -m -s /bin/bash -G wheel,audio,video,input,storage,optical arcade
# No password — auto-login handles access
passwd -d arcade
passwd -d root

# ── 1b. Base system identity (prevents interactive systemd-firstboot) ────────
echo "project-r" > /etc/hostname
echo "LANG=C.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# ── 2. sudo without password for wheel group ─────────────────────────────────
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/wheel-nopasswd
chmod 440 /etc/sudoers.d/wheel-nopasswd

# ── 3. Auto-login on tty1 via systemd getty override ─────────────────────────
echo "==> Configuring auto-login for arcade on tty1"
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin arcade --noclear %I $TERM
EOF

# ── 4. Start X + ES-DE on login ──────────────────────────────────────────────
echo "==> Setting up .bash_profile to launch ES-DE on tty1"
cat > /home/arcade/.bash_profile << 'EOF'
# Auto-start gaming session on tty1
if [[ -z "${DISPLAY}" && "${XDG_VTNR}" == "1" ]]; then
    exec startx ~/.xinitrc
fi
EOF

cat > /home/arcade/.xinitrc << 'EOF'
#!/bin/bash
# Gaming session — launch ES-DE fullscreen
export SDL_GAMECONTROLLERCONFIG_FILE="$HOME/.config/project-r/input/sdl_gamecontrollerdb.txt"
export QT_QPA_PLATFORM=xcb

# Start pipewire audio
pipewire &
wireplumber &

# Disable screen blanking
xset s off
xset -dpms
xset s noblank

# Launch ES-DE
exec es-de --no-splash
EOF
chmod +x /home/arcade/.xinitrc /home/arcade/.bash_profile

# ── 5. Configure ES-DE: fullscreen, no splash ────────────────────────────────
echo "==> Configuring ES-DE defaults"
# ES-DE 3.x reads ~/ES-DE/settings/es_settings.xml (flat elements, no root node).
# Theme stays on the ES-DE default until pr-theme is packaged.
mkdir -p /home/arcade/ES-DE/settings /home/arcade/games
cat > /home/arcade/ES-DE/settings/es_settings.xml << 'EOF'
<?xml version="1.0"?>
<string name="ROMDirectory" value="~/games" />
EOF

# ── 6. Configure pacman to include Project-R repo ────────────────────────────
echo "==> Adding project-r-repo to /etc/pacman.conf"
if ! grep -q "project-r-repo" /etc/pacman.conf; then
    sed -i '/^\[core\]/i Include = /etc/pacman.d/project-r.conf\n' /etc/pacman.conf
fi

# ── 7. Enable essential services ─────────────────────────────────────────────
echo "==> Enabling systemd services"
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable pr-mediad
systemctl enable pr-builder
systemctl enable pr-meta
systemctl enable pr-achieve
systemctl enable pr-controller
systemctl enable pr-maestro

# ── 8. Fix ownership ─────────────────────────────────────────────────────────
chown -R arcade:arcade /home/arcade

echo "==> customize_airootfs.sh complete"
