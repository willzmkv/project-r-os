#!/usr/bin/env bash
# return-to-gaming.sh — Desktop Mode → Gaming Mode.
#
# Called by the "Return to Gaming Mode" tray widget / app-menu entry, or by the
# hotkey daemon (Start+Select) while in Desktop Mode. It records the request
# FIRST — when started from the tray widget this script lives inside the Plasma
# session and may be killed while Plasma tears down — then logs Plasma out.
# When startplasma-wayland returns, project-r-session (the single session
# owner on tty1) starts the gaming session (ES-DE) again.
#
#   PR_DRY_RUN=1   print the actions instead of touching processes
#   PR_LOGOUT_TIMEOUT  seconds to wait for a clean logout (default 30)

set -euo pipefail

export PR_SESSION="gaming"
export PR_SESSION_FILE="${XDG_RUNTIME_DIR:-/tmp}/pr-session"

echo "$PR_SESSION" > "$PR_SESSION_FILE"

# ── dry-run mode ───────────────────────────────────────────────────────────────
if [[ "${PR_DRY_RUN:-0}" == "1" ]]; then
  echo "DRYRUN: kill plasma (org.kde.Shutdown.logout)"
  echo "DRYRUN: es-de (launched by project-r-session)"
  exit 0
fi

# ── real mode ─────────────────────────────────────────────────────────────────
uid="$(id -u)"
# The hotkey daemon runs outside Plasma: point it at the user's session bus.
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR:-/run/user/$uid}/bus}"

plasma_running() {
  pgrep -u "$uid" -x kwin_wayland >/dev/null || pgrep -u "$uid" -x plasmashell >/dev/null
}

# Plasma 6: org.kde.Shutdown.logout ends the session without a prompt but
# still lets applications save/close. ksmserver's logout is the older path.
request_logout() {
  if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout >/dev/null 2>&1 && return 0
    qdbus6 org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout 0 0 0 >/dev/null 2>&1 && return 0
  fi
  if command -v dbus-send >/dev/null 2>&1; then
    dbus-send --session --print-reply --dest=org.kde.Shutdown /Shutdown \
      org.kde.Shutdown.logout >/dev/null 2>&1 && return 0
  fi
  return 1
}

if ! plasma_running; then
  exit 0
fi

if request_logout; then
  timeout="${PR_LOGOUT_TIMEOUT:-30}"
  for _ in $(seq 1 $(( timeout * 2 ))); do
    plasma_running || exit 0
    sleep 0.5
  done
  # Still running: an application vetoed the logout (e.g. unsaved work).
  # Stay in Desktop Mode and keep pr-session truthful for the hotkey toggle.
  echo "desktop" > "$PR_SESSION_FILE"
  echo "return-to-gaming: logout was cancelled, staying in Desktop Mode" >&2
  exit 1
fi

# No usable D-Bus logout (Plasma hung or bus gone): stop the compositor so
# startplasma-wayland returns and project-r-session can continue.
echo "return-to-gaming: D-Bus logout unavailable, terminating Plasma" >&2
pkill -TERM -u "$uid" -x plasmashell 2>/dev/null || true
pkill -TERM -u "$uid" -x kwin_wayland 2>/dev/null || true
for _ in $(seq 1 10); do
  plasma_running || exit 0
  sleep 0.5
done
pkill -KILL -u "$uid" -x plasmashell 2>/dev/null || true
pkill -KILL -u "$uid" -x kwin_wayland 2>/dev/null || true
