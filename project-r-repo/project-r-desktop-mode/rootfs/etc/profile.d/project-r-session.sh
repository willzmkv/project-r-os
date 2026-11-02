# shellcheck shell=sh
# /etc/profile.d/project-r-session.sh — project-r-desktop-mode
# Hands the tty1 autologin of the Project-R user to project-r-session, the
# single owner of the graphical session (ES-DE gaming / KDE Plasma desktop).
#
# project-r-session is *run*, not exec'd: if it gives up after repeated
# failures this login shell stays usable on tty1 (with a message pointing at
# the log) instead of getty restart-looping into a black screen.
if [ "${XDG_VTNR:-}" = "1" ] && [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ] \
    && [ -z "${PR_SESSION_ACTIVE:-}" ] \
    && [ "$(id -un)" = "${PR_SESSION_USER:-arcade}" ] \
    && [ -x "${PR_SESSION_BIN:-/usr/lib/project-r/project-r-session}" ]; then
    "${PR_SESSION_BIN:-/usr/lib/project-r/project-r-session}"
fi
