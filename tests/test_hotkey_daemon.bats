#!/usr/bin/env bats
# Desktop Mode — Start+Select hotkey daemon.
# Run: bats tests/test_hotkey_daemon.bats

SCRIPTS_DIR="$(cd "$BATS_TEST_DIRNAME/../project-r-repo/project-r-desktop-mode/scripts" && pwd)"

@test "hotkey-daemon.sh is executable" {
  [ -x "$SCRIPTS_DIR/hotkey-daemon.sh" ]
}

@test "hotkey-daemon.sh --check-deps exits 0 when python3-evdev present" {
  # Mock: create a fake python3 that succeeds importing evdev
  FAKE_BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$FAKE_BIN"
  cat > "$FAKE_BIN/python3" <<'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"import evdev"* ]]; then exit 0; fi
exit 1
EOF
  chmod +x "$FAKE_BIN/python3"
  PATH="$FAKE_BIN:$PATH" run bash "$SCRIPTS_DIR/hotkey-daemon.sh" --check-deps
  [ "$status" -eq 0 ]
}

@test "hotkey-daemon.sh --check-deps exits 1 when python3-evdev missing" {
  FAKE_BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$FAKE_BIN"
  cat > "$FAKE_BIN/python3" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
  chmod +x "$FAKE_BIN/python3"
  PATH="$FAKE_BIN:$PATH" run bash "$SCRIPTS_DIR/hotkey-daemon.sh" --check-deps
  [ "$status" -eq 1 ]
}

@test "hotkey-daemon.sh --help prints usage" {
  run bash "$SCRIPTS_DIR/hotkey-daemon.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}
