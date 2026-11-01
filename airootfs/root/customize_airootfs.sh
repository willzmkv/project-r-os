#!/usr/bin/env bash
set -euo pipefail

echo "==> [project-r] Running customize_airootfs.sh"

# ── 1. Create arcade user ────────────────────────────────────────────────────
echo "==> Creating arcade user"
useradd -m -s /bin/bash -G wheel,audio,video,input,storage,optical arcade
# No password — auto-login handles access
passwd -d arcade
passwd -d root

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
exec emulationstation --no-splash
EOF
chmod +x /home/arcade/.xinitrc /home/arcade/.bash_profile

# ── 5. Configure ES-DE: fullscreen, no splash ────────────────────────────────
echo "==> Configuring ES-DE defaults"
mkdir -p /home/arcade/.config/emulationstation
cat > /home/arcade/.config/emulationstation/es_settings.xml << 'EOF'
<?xml version="1.0"?>
<config>
  <bool name="ShowSplashScreen" value="false" />
  <bool name="Windowed" value="false" />
  <bool name="StartupSystem" value="" />
  <string name="Theme" value="project-r" />
</config>
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
