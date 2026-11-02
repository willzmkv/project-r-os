#!/usr/bin/env bash
# project-r-session — the single owner of the Project-R graphical session.
#
# Started on tty1 by the getty autologin of 'arcade'
# (getty@tty1 drop-in → login shell → /etc/profile.d/project-r-session.sh).
# It alternates, in the same logind session, between:
#   gaming   startx /usr/lib/project-r/xinitrc → gaming-session.sh → es-de
#   desktop  startplasma-wayland   (Plasma 6.8 ships no X11 session)
# The next mode is read from $XDG_RUNTIME_DIR/pr-session, which is written by
# switch-to-desktop.sh, return-to-gaming.sh and gaming-session.sh.
#
# Failure policy — never restart-loop on a black screen:
#   * a session that ends within PR_QUICK_FAIL_SECS without requesting a
#     switch counts as a failure
#   * 2 failures in a row in Gaming Mode → fall back to Desktop Mode
#   * a Desktop Mode session that ends (logout or crash) → Gaming Mode
#   * PR_MAX_FAILS failures in a row → stop, print where the log is, and
#     return to the tty1 login shell (the profile hook does not exec us)
#
# Usage: project-r-session [--seed-only]
#   --seed-only  copy missing default configs into $HOME and exit
#
# Defaults for configs (ES-DE, KDE, RetroArch, Ghostty) are copied from
# /usr/share/project-r/skel into $HOME when missing; user edits are kept.

set -uo pipefail

PR_LIB_DIR="${PR_LIB_DIR:-/usr/lib/project-r}"
PR_SKEL_DIR="${PR_SKEL_DIR:-/usr/share/project-r/skel}"
PR_GAMING_CMD="${PR_GAMING_CMD:-startx $PR_LIB_DIR/xinitrc}"
PR_DESKTOP_CMD="${PR_DESKTOP_CMD:-/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland}"
PR_QUICK_FAIL_SECS="${PR_QUICK_FAIL_SECS:-15}"
PR_MAX_FAILS="${PR_MAX_FAILS:-4}"
PR_GAMING_FAILS_BEFORE_DESKTOP="${PR_GAMING_FAILS_BEFORE_DESKTOP:-2}"
PR_SWITCH_DELAY="${PR_SWITCH_DELAY:-1}"
PR_MAX_CYCLES="${PR_MAX_CYCLES:-0}"   # test hook: stop after N sessions (0 = never)

SESSION_FILE="${XDG_RUNTIME_DIR:-/tmp}/pr-session"
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/project-r"
LOG="$LOG_DIR/session.log"

log() { printf '%s %s\n' "$(date '+%F %T')" "$*" >>"$LOG"; }
say() { log "$*"; printf 'project-r-session: %s\n' "$*" >&2; }

read_mode() {
  local mode
  mode="$(cat "$SESSION_FILE" 2>/dev/null || true)"
  case "$mode" in
    desktop) echo desktop ;;
    *)       echo gaming ;;
  esac
}

# Copy every default from the skel dir that does not exist in $HOME yet.
seed_home() {
  local rel dest
  mkdir -p "$HOME/games"
  [[ -d "$PR_SKEL_DIR" ]] || return 0
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    dest="$HOME/$rel"
    [[ -e "$dest" ]] && continue
    mkdir -p "$(dirname "$dest")" && cp "$PR_SKEL_DIR/$rel" "$dest" && log "seeded ~/$rel"
  done < <(cd "$PR_SKEL_DIR" && find . -type f -print0)
}

# PipeWire is socket-activated by the systemd user manager; make sure it is
# up for both modes. Without a user manager fall back to starting it by hand.
start_audio() {
  if systemctl --user start pipewire.socket pipewire-pulse.socket wireplumber.service 2>>"$LOG"; then
    return 0
  fi
  log "systemd user manager unavailable, starting pipewire manually"
  if command -v pipewire >/dev/null && ! pgrep -u "$(id -u)" -x pipewire >/dev/null; then
    pipewire >>"$LOG" 2>&1 &
  fi
  if command -v wireplumber >/dev/null && ! pgrep -u "$(id -u)" -x wireplumber >/dev/null; then
    wireplumber >>"$LOG" 2>&1 &
  fi
}

run_mode() {
  local -a cmd
  if [[ "$1" == gaming ]]; then
    # Plasma imports WAYLAND_DISPLAY into the user manager; drop it before X.
    systemctl --user unset-environment WAYLAND_DISPLAY 2>/dev/null || true
    read -r -a cmd <<<"$PR_GAMING_CMD"
  else
    read -r -a cmd <<<"$PR_DESKTOP_CMD"
  fi
  "${cmd[@]}" >>"$LOG" 2>&1
}

give_up() {
  say "graphical session failed $1 times in a row, stopping"
  cat >&2 <<EOF

=====================================================================
 Project-R could not start a graphical session.
   Session log : $LOG
   Xorg log    : ~/.local/share/xorg/Xorg.0.log
   Plasma log  : journalctl --user -b
 Retry with:     project-r-session
 Desktop only:   PR_START_MODE=desktop project-r-session
=====================================================================

EOF
}

main() {
  export PR_SESSION_ACTIVE=1
  mkdir -p "$LOG_DIR"
  seed_home
  if [[ "${1:-}" == "--seed-only" ]]; then
    return 0
  fi

  log "project-r-session starting on $(tty 2>/dev/null || echo '?')"
  start_audio

  local mode="${PR_START_MODE:-gaming}"
  [[ "$mode" == desktop ]] || mode=gaming
  local fails=0 gaming_fails=0 cycles=0 start rc dur requested

  while :; do
    echo "$mode" >"$SESSION_FILE"
    log "starting $mode session"
    start=$SECONDS
    run_mode "$mode"
    rc=$?
    dur=$(( SECONDS - start ))
    requested="$(read_mode)"
    log "$mode session ended (rc=$rc, ${dur}s, requested=$requested)"

    if (( dur < PR_QUICK_FAIL_SECS )) && [[ "$requested" == "$mode" ]]; then
      fails=$(( fails + 1 ))
      [[ "$mode" == gaming ]] && gaming_fails=$(( gaming_fails + 1 ))
      say "$mode session failed quickly (rc=$rc, $fails in a row)"
    else
      fails=0
      gaming_fails=0
    fi

    if (( fails >= PR_MAX_FAILS )); then
      give_up "$fails"
      return 1
    fi
    cycles=$(( cycles + 1 ))
    if (( PR_MAX_CYCLES > 0 && cycles >= PR_MAX_CYCLES )); then
      return 0
    fi

    if [[ "$mode" == gaming ]]; then
      if (( gaming_fails >= PR_GAMING_FAILS_BEFORE_DESKTOP )); then
        say "Gaming Mode keeps failing, falling back to Desktop Mode"
        mode=desktop
      else
        mode="$requested"
      fi
    else
      mode=gaming
    fi
    sleep "$PR_SWITCH_DELAY"   # let the VT/DRM master settle between compositors
  done
}

main "$@"
