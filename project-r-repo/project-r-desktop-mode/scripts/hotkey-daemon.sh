#!/usr/bin/env bash
# hotkey-daemon.sh — watches gamepads for Start+Select, triggers session switch
# Wraps a Python evdev listener (hotkey-daemon.py). Requires python-evdev.
# Started by the pr-hotkey.service systemd *user* unit.

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── --help ─────────────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--help" ]]; then
  cat <<'USAGE'
Usage: hotkey-daemon.sh [OPTIONS]

  --help        Show this help message
  --check-deps  Verify python-evdev is installed (exit 0=ok, 1=missing)

Watches all /dev/input/event* gamepads for Start+Select held together
(PR_HOTKEY_HOLD seconds, default 2.0). When detected it runs
switch-to-desktop.sh or return-to-gaming.sh depending on the mode recorded
in $XDG_RUNTIME_DIR/pr-session.
USAGE
  exit 0
fi

# ── --check-deps ───────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--check-deps" ]]; then
  if python3 -c "import evdev" 2>/dev/null; then
    echo "OK: python-evdev found"
    exit 0
  else
    echo "ERROR: python-evdev not found. Install: sudo pacman -S python-evdev"
    exit 1
  fi
fi

# ── real mode ─────────────────────────────────────────────────────────────────
exec python3 "$SCRIPTS_DIR/hotkey-daemon.py" "$SCRIPTS_DIR"
