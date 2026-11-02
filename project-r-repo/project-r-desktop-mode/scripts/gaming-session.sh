#!/usr/bin/env bash
# gaming-session.sh — Project-R Gaming Mode: ES-DE fullscreen.
#
# Runs as the X client of the gaming session (project-r-session → startx
# /usr/lib/project-r/xinitrc → this script). It does NOT loop: when ES-DE exits
# the X session ends and project-r-session (the single session owner) decides
# what runs next, based on $XDG_RUNTIME_DIR/pr-session:
#   * killed by switch-to-desktop.sh → pr-session already says "desktop"
#   * quit by the user (exit 0)      → request Desktop Mode, so quitting ES-DE
#                                      never leaves a black screen
#   * crashed (exit != 0)            → stays "gaming"; project-r-session restarts
#                                      it and falls back after repeated crashes
#
#   PR_DRY_RUN=1   print the action instead of launching ES-DE
#   --source-only  only export the session variables (used by tests)

set -euo pipefail

export PR_SESSION="gaming"
export PR_SESSION_FILE="${XDG_RUNTIME_DIR:-/tmp}/pr-session"
PR_ESDE_BIN="${PR_ESDE_BIN:-es-de}"

echo "$PR_SESSION" > "$PR_SESSION_FILE"

# ── source-only mode (used by tests) ──────────────────────────────────────────
if [[ "${1:-}" == "--source-only" ]]; then
  # shellcheck disable=SC2317  # exit is reached when executed, not sourced
  return 0 2>/dev/null || exit 0
fi

# ── dry-run mode ───────────────────────────────────────────────────────────────
if [[ "${PR_DRY_RUN:-0}" == "1" ]]; then
  echo "DRYRUN: $PR_ESDE_BIN --no-splash"
  exit 0
fi

# ── real mode ─────────────────────────────────────────────────────────────────
# Controller mappings written by pr-controller (SDL ignores a missing file)
export SDL_GAMECONTROLLERCONFIG_FILE="${SDL_GAMECONTROLLERCONFIG_FILE:-$HOME/.config/project-r/input/sdl_gamecontrollerdb.txt}"
# Qt emulators launched from ES-DE (rpcs3, pcsx2, duckstation, ...) are on X here
export QT_QPA_PLATFORM=xcb

rc=0
"$PR_ESDE_BIN" --no-splash || rc=$?

if [[ $rc -eq 0 && "$(cat "$PR_SESSION_FILE" 2>/dev/null || true)" == "gaming" ]]; then
  echo "desktop" > "$PR_SESSION_FILE"
fi
exit "$rc"
