#!/usr/bin/env bats
# Desktop Mode (project-r-desktop-mode) — session scripts and shipped config.
# Run: bats tests/test_session_scripts.bats

PKG_DIR="$(cd "$BATS_TEST_DIRNAME/../project-r-repo/project-r-desktop-mode" && pwd)"
SCRIPTS_DIR="$PKG_DIR/scripts"

setup() {
  # Every test gets its own runtime dir so the pr-session file never leaks
  # into the real $XDG_RUNTIME_DIR or between tests.
  export XDG_RUNTIME_DIR="$BATS_TEST_TMPDIR"
}

# ── gaming-session.sh ──────────────────────────────────────────────────────────

@test "gaming-session.sh is executable" {
  [ -x "$SCRIPTS_DIR/gaming-session.sh" ]
}

@test "gaming-session.sh exports PR_SESSION=gaming" {
  run bash -c "source $SCRIPTS_DIR/gaming-session.sh --source-only 2>/dev/null; echo \$PR_SESSION"
  [ "$output" = "gaming" ]
}

@test "gaming-session.sh calls es-de when PR_DRY_RUN=1" {
  PR_DRY_RUN=1 run bash "$SCRIPTS_DIR/gaming-session.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRYRUN: es-de"* ]]
}

@test "gaming-session.sh requests Desktop Mode when ES-DE is quit normally" {
  fake="$BATS_TEST_TMPDIR/es-de"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$fake"; chmod +x "$fake"
  PR_ESDE_BIN="$fake" run bash "$SCRIPTS_DIR/gaming-session.sh"
  [ "$status" -eq 0 ]
  [ "$(cat "$XDG_RUNTIME_DIR/pr-session")" = "desktop" ]
}

@test "gaming-session.sh keeps Gaming Mode and propagates the code when ES-DE crashes" {
  fake="$BATS_TEST_TMPDIR/es-de"
  printf '#!/usr/bin/env bash\nexit 139\n' > "$fake"; chmod +x "$fake"
  PR_ESDE_BIN="$fake" run bash "$SCRIPTS_DIR/gaming-session.sh"
  [ "$status" -eq 139 ]
  [ "$(cat "$XDG_RUNTIME_DIR/pr-session")" = "gaming" ]
}

# ── switch-to-desktop.sh ───────────────────────────────────────────────────────

@test "switch-to-desktop.sh is executable" {
  [ -x "$SCRIPTS_DIR/switch-to-desktop.sh" ]
}

@test "switch-to-desktop.sh sets PR_SESSION=desktop when PR_DRY_RUN=1" {
  PR_DRY_RUN=1 run bash "$SCRIPTS_DIR/switch-to-desktop.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"PR_SESSION=desktop"* ]]
}

@test "switch-to-desktop.sh prints kill-es-de action when PR_DRY_RUN=1" {
  PR_DRY_RUN=1 run bash "$SCRIPTS_DIR/switch-to-desktop.sh"
  [[ "$output" == *"DRYRUN: kill es-de"* ]]
}

@test "switch-to-desktop.sh prints start-plasma action when PR_DRY_RUN=1" {
  # Plasma 6.8 is Wayland-only (no startplasma-x11 in Arch any more).
  PR_DRY_RUN=1 run bash "$SCRIPTS_DIR/switch-to-desktop.sh"
  [[ "$output" == *"DRYRUN: startplasma-wayland"* ]]
}

# ── return-to-gaming.sh ────────────────────────────────────────────────────────

@test "return-to-gaming.sh is executable" {
  [ -x "$SCRIPTS_DIR/return-to-gaming.sh" ]
}

@test "return-to-gaming.sh prints kill-plasma action when PR_DRY_RUN=1" {
  PR_DRY_RUN=1 run bash "$SCRIPTS_DIR/return-to-gaming.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRYRUN: kill plasma"* ]]
}

@test "return-to-gaming.sh prints start-es-de action when PR_DRY_RUN=1" {
  PR_DRY_RUN=1 run bash "$SCRIPTS_DIR/return-to-gaming.sh"
  [[ "$output" == *"DRYRUN: es-de"* ]]
}

# ── project-r-session (single owner of the tty1 graphical session) ────────────

ROOTFS_DIR="$PKG_DIR/rootfs"

# Isolated HOME/skel, no delays, fake systemctl, fake session commands.
session_env() {
  export HOME="$BATS_TEST_TMPDIR/home"; mkdir -p "$HOME"
  export PR_SKEL_DIR="$BATS_TEST_TMPDIR/skel"; mkdir -p "$PR_SKEL_DIR"
  export PR_SWITCH_DELAY=0 PR_QUICK_FAIL_SECS=0 PR_MAX_CYCLES=10
  unset XDG_STATE_HOME PR_SESSION_ACTIVE PR_START_MODE
  FAKE="$BATS_TEST_TMPDIR/fake"; mkdir -p "$FAKE"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$FAKE/systemctl"; chmod +x "$FAKE/systemctl"
  export PATH="$FAKE:$PATH"
  CALLS="$BATS_TEST_TMPDIR/calls"
  export PR_GAMING_CMD="$FAKE/gaming" PR_DESKTOP_CMD="$FAKE/desktop"
}

# fake_mode NAME BODY — fake session command that logs NAME, then runs BODY
fake_mode() {
  printf '#!/usr/bin/env bash\necho %s >> "%s"\n%s\n' "$1" "$CALLS" "$2" > "$FAKE/$1"
  chmod +x "$FAKE/$1"
}

calls() { paste -sd, "$CALLS"; }

@test "project-r-session starts Gaming Mode and follows switch requests" {
  session_env
  fake_mode gaming  'echo desktop > "$XDG_RUNTIME_DIR/pr-session"'
  fake_mode desktop 'echo gaming > "$XDG_RUNTIME_DIR/pr-session"'
  PR_MAX_CYCLES=3 run bash "$SCRIPTS_DIR/project-r-session.sh"
  [ "$status" -eq 0 ]
  [ "$(calls)" = "gaming,desktop,gaming" ]
}

@test "project-r-session returns to Gaming Mode when Plasma is logged out" {
  session_env
  fake_mode gaming  'echo desktop > "$XDG_RUNTIME_DIR/pr-session"'
  fake_mode desktop 'exit 0'   # plain logout from the Plasma menu: no request
  PR_MAX_CYCLES=3 run bash "$SCRIPTS_DIR/project-r-session.sh"
  [ "$status" -eq 0 ]
  [ "$(calls)" = "gaming,desktop,gaming" ]
}

@test "project-r-session falls back to Desktop Mode when Gaming Mode keeps failing" {
  session_env
  fake_mode gaming  'exit 1'
  fake_mode desktop 'echo gaming > "$XDG_RUNTIME_DIR/pr-session"'
  PR_QUICK_FAIL_SECS=100 PR_MAX_CYCLES=3 run bash "$SCRIPTS_DIR/project-r-session.sh"
  [ "$status" -eq 0 ]
  [ "$(calls)" = "gaming,gaming,desktop" ]
  [[ "$output" == *"falling back to Desktop Mode"* ]]
}

@test "project-r-session gives up visibly instead of restart-looping" {
  session_env
  fake_mode gaming  'exit 1'
  fake_mode desktop 'exit 1'
  PR_QUICK_FAIL_SECS=100 PR_MAX_CYCLES=50 run bash "$SCRIPTS_DIR/project-r-session.sh"
  [ "$status" -eq 1 ]
  [ "$(calls)" = "gaming,gaming,desktop,gaming" ]
  [[ "$output" == *"could not start a graphical session"* ]]
  grep -q "failed quickly" "$HOME/.local/state/project-r/session.log"
}

@test "project-r-session --seed-only copies defaults without clobbering user files" {
  session_env
  mkdir -p "$PR_SKEL_DIR/.config/demo" "$HOME/.config/demo"
  echo default > "$PR_SKEL_DIR/.config/demo/a.conf"
  echo default > "$PR_SKEL_DIR/.config/demo/b.conf"
  echo mine    > "$HOME/.config/demo/a.conf"
  run bash "$SCRIPTS_DIR/project-r-session.sh" --seed-only
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.config/demo/a.conf")" = "mine" ]
  [ "$(cat "$HOME/.config/demo/b.conf")" = "default" ]
  [ -d "$HOME/games" ]
  [ ! -s "$BATS_TEST_TMPDIR/calls" ]
}

@test "shipped defaults seed ES-DE settings with ROMDirectory ~/games" {
  session_env
  PR_SKEL_DIR="$ROOTFS_DIR/home/arcade" run bash "$SCRIPTS_DIR/project-r-session.sh" --seed-only
  [ "$status" -eq 0 ]
  grep -qx '<string name="ROMDirectory" value="~/games" />' "$HOME/ES-DE/settings/es_settings.xml"
  head -1 "$HOME/ES-DE/settings/es_settings.xml" | grep -qx '<?xml version="1.0"?>'
}

@test "xinitrc hands the X session to gaming-session.sh" {
  grep -q "exec /usr/lib/project-r/gaming-session.sh" "$SCRIPTS_DIR/xinitrc"
}

# ── tty1 login hand-off ────────────────────────────────────────────────────────

hook_env() {
  export PR_SESSION_BIN="$BATS_TEST_TMPDIR/session-bin"
  printf '#!/bin/sh\necho SESSION-STARTED\n' > "$PR_SESSION_BIN"; chmod +x "$PR_SESSION_BIN"
  export PR_SESSION_USER="$(id -un)"
  unset DISPLAY WAYLAND_DISPLAY PR_SESSION_ACTIVE
}

@test "profile hook starts project-r-session for the arcade user on tty1" {
  hook_env
  XDG_VTNR=1 run sh -c ". '$ROOTFS_DIR/etc/profile.d/project-r-session.sh'"
  [ "$output" = "SESSION-STARTED" ]
}

@test "profile hook does nothing on other ttys or inside a graphical session" {
  hook_env
  XDG_VTNR=2 run sh -c ". '$ROOTFS_DIR/etc/profile.d/project-r-session.sh'"
  [ -z "$output" ]
  XDG_VTNR=1 DISPLAY=:0 run sh -c ". '$ROOTFS_DIR/etc/profile.d/project-r-session.sh'"
  [ -z "$output" ]
  XDG_VTNR=1 PR_SESSION_USER=someone-else run sh -c ". '$ROOTFS_DIR/etc/profile.d/project-r-session.sh'"
  [ -z "$output" ]
}

@test "getty drop-in auto-logs in arcade on tty1" {
  grep -q -- "--autologin arcade" \
    "$ROOTFS_DIR/usr/lib/systemd/system/getty@tty1.service.d/project-r-autologin.conf"
}

@test "pr-hotkey.service is a user unit running the hotkey daemon" {
  unit="$ROOTFS_DIR/usr/lib/systemd/user/pr-hotkey.service"
  grep -q "^ExecStart=/usr/lib/project-r/hotkey-daemon.sh$" "$unit"
  grep -q "^WantedBy=default.target$" "$unit"
}

# ── KDE config files ───────────────────────────────────────────────────────────

KDE_CFG="$ROOTFS_DIR/home/arcade/.config"

@test "kwinrc disables electric borders" {
  grep -q "Bottom=None" "$KDE_CFG/kwinrc"
  grep -q "TopLeft=None" "$KDE_CFG/kwinrc"
}

@test "kwinrc disables the Plasma 6 Overview hot corner" {
  # 9 = ElectricNone; Plasma 6 binds Overview to the top-left corner by default
  grep -A1 "^\[Effect-overview\]" "$KDE_CFG/kwinrc" | grep -q "^BorderActivate=9$"
}

@test "ksplashrc sets splash to None" {
  # The plan put this in plasmarc; KSplash reads ksplashrc.
  grep -q "^Theme=None$" "$KDE_CFG/ksplashrc"
  grep -q "^Engine=none$" "$KDE_CFG/ksplashrc"
}

@test "plasmarc selects the Breeze Dark Plasma theme" {
  grep -q "^name=breeze-dark$" "$KDE_CFG/plasmarc"
}

@test "baloo file indexing is disabled" {
  grep -q "^Indexing-Enabled=false$" "$KDE_CFG/baloofilerc"
}

@test "plasma applets include system tray" {
  grep -q "org.kde.plasma.systemtray" \
    "$KDE_CFG/plasma-org.kde.plasma.desktop-appletsrc"
  grep -q "^plugin=org.kde.plasma.private.systemtray$" \
    "$KDE_CFG/plasma-org.kde.plasma.desktop-appletsrc"
}

@test "plasma applets include return-to-gaming widget" {
  grep -q "project-r.return-to-gaming" \
    "$KDE_CFG/plasma-org.kde.plasma.desktop-appletsrc"
}

@test "plasma taskbar has no pinned launchers" {
  grep -qx "launchers=" \
    "$KDE_CFG/plasma-org.kde.plasma.desktop-appletsrc"
}

@test "plasma tray points at the systray containment it defines" {
  f="$KDE_CFG/plasma-org.kde.plasma.desktop-appletsrc"
  id="$(sed -n 's/^SystrayContainmentId=//p' "$f")"
  [ -n "$id" ]
  grep -A6 "^\[Containments\]\[$id\]$" "$f" | grep -q "plugin=org.kde.plasma.private.systemtray"
}
