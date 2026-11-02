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
