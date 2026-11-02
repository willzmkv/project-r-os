#!/usr/bin/env bash
# switch-to-desktop.sh — Gaming Mode → Desktop Mode (KDE Plasma 6, Wayland).
#
# Triggered by the hotkey daemon (Start+Select). Records the request in
# $XDG_RUNTIME_DIR/pr-session and ends ES-DE. Ending ES-DE ends the X session;
# project-r-session (the single session owner on tty1) then starts
# startplasma-wayland in the same login session. Plasma 6.8 ships no X11
# session, so Plasma cannot be started inside ES-DE's X server any more.
#
#   PR_DRY_RUN=1   print the actions instead of touching processes

set -euo pipefail

export PR_SESSION="desktop"
export PR_SESSION_FILE="${XDG_RUNTIME_DIR:-/tmp}/pr-session"

echo "$PR_SESSION" > "$PR_SESSION_FILE"
echo "PR_SESSION=desktop"

# ── dry-run mode ───────────────────────────────────────────────────────────────
if [[ "${PR_DRY_RUN:-0}" == "1" ]]; then
  echo "DRYRUN: kill es-de"
  echo "DRYRUN: startplasma-wayland (launched by project-r-session)"
  exit 0
fi

# ── real mode ─────────────────────────────────────────────────────────────────
uid="$(id -u)"

# Ask ES-DE to quit; SIGKILL if it is still alive after ~5 s (e.g. blocked
# waiting on a running emulator). Only this user's processes are touched.
if pgrep -u "$uid" -x es-de >/dev/null; then
  pkill -TERM -u "$uid" -x es-de || true
  for _ in $(seq 1 10); do
    pgrep -u "$uid" -x es-de >/dev/null || break
    sleep 0.5
  done
  pkill -KILL -u "$uid" -x es-de 2>/dev/null || true
fi
