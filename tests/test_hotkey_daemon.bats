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

@test "hotkey-daemon.sh execs the python listener with its scripts dir" {
  FAKE_BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$FAKE_BIN"
  printf '#!/usr/bin/env bash\necho "python3 $*"\n' > "$FAKE_BIN/python3"
  chmod +x "$FAKE_BIN/python3"
  PATH="$FAKE_BIN:$PATH" run bash "$SCRIPTS_DIR/hotkey-daemon.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"hotkey-daemon.py $SCRIPTS_DIR"* ]]
}

# ── hotkey-daemon.py logic (no gamepad needed: time is injected) ──────────────

# Runs a python snippet with the daemon module imported as `hd`.
run_hd() {
  run python3 -c "
import importlib.util, sys
spec = importlib.util.spec_from_file_location('hd', '$SCRIPTS_DIR/hotkey-daemon.py')
hd = importlib.util.module_from_spec(spec); spec.loader.exec_module(hd)
$1
print('OK')"
}

@test "combo fires once after Start+Select are held for the hold time" {
  run_hd "
d = hd.ComboDetector(hold=2.0)
d.feed(hd.BTN_START, 1, 0.0); d.feed(hd.BTN_SELECT, 1, 0.1)
assert not d.due(1.0)
assert d.due(2.2)
assert not d.due(3.0), 'must fire only once per press'"
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}

@test "releasing a button before the hold time cancels the combo" {
  run_hd "
d = hd.ComboDetector(hold=2.0)
d.feed(hd.BTN_START, 1, 0.0); d.feed(hd.BTN_SELECT, 1, 0.0)
d.feed(hd.BTN_SELECT, 0, 1.0)
assert not d.due(2.5)"
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}

@test "combo can fire again after both buttons are released and re-pressed" {
  run_hd "
d = hd.ComboDetector(hold=1.0)
d.feed(hd.BTN_START, 1, 0.0); d.feed(hd.BTN_SELECT, 1, 0.0)
assert d.due(1.0)
d.feed(hd.BTN_START, 0, 1.5); d.feed(hd.BTN_START, 1, 2.0)
assert d.due(3.0)"
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}

@test "autorepeat events and other buttons do not affect the combo" {
  run_hd "
d = hd.ComboDetector(hold=1.0)
d.feed(hd.BTN_START, 1, 0.0)
d.feed(304, 1, 0.0)            # BTN_SOUTH
d.feed(hd.BTN_START, 2, 0.5)   # autorepeat
assert not d.due(5.0)
d.feed(hd.BTN_SELECT, 1, 5.0)
assert d.due(6.0)"
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}

@test "switcher picks the script from the current pr-session mode" {
  run_hd "
from pathlib import Path
f = Path('$BATS_TEST_TMPDIR/pr-session')
s = hd.Switcher(Path('/scripts'), f, cooldown=0, run=lambda p: None)
assert s.target_script().name == 'switch-to-desktop.sh', 'missing file = gaming'
f.write_text('gaming\n');  assert s.target_script().name == 'switch-to-desktop.sh'
f.write_text('desktop\n'); assert s.target_script().name == 'return-to-gaming.sh'"
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}

@test "switcher ignores a second combo inside the cooldown window" {
  run_hd "
from pathlib import Path
ran = []
s = hd.Switcher(Path('/scripts'), Path('$BATS_TEST_TMPDIR/none'), cooldown=5.0, run=ran.append)
assert s.trigger(10.0) is not None
assert s.trigger(12.0) is None
assert s.trigger(15.5) is not None
assert len(ran) == 2"
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}

# Fake evdev device: yields scripted (delay, code, value) key events.
FAKE_DEV_PY="
import asyncio
from pathlib import Path
class Ev:
    def __init__(s, c, v): s.type, s.code, s.value = hd.ecodes.EV_KEY, c, v
class FakeDev:
    path, name, closed = '/dev/input/fake', 'fake pad', False
    def __init__(s, script): s.script = script
    async def async_read_loop(s):
        for delay, code, value in s.script:
            await asyncio.sleep(delay)
            yield Ev(code, value)
    def close(s): s.closed = True
ran = []
sw = hd.Switcher(Path('/s'), Path('$BATS_TEST_TMPDIR/none'), cooldown=0, run=ran.append)
"

@test "watch_device triggers the switch when the combo is held on a pad" {
  run_hd "$FAKE_DEV_PY
dev = FakeDev([(0, hd.BTN_START, 1), (0, hd.BTN_SELECT, 1), (0.4, hd.BTN_SELECT, 0)])
asyncio.run(hd.watch_device(dev, sw, hold=0.2))
assert [p.name for p in ran] == ['switch-to-desktop.sh'], ran
assert dev.closed"
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}

@test "watch_device does not trigger on a quick Start+Select tap" {
  run_hd "$FAKE_DEV_PY
dev = FakeDev([(0, hd.BTN_START, 1), (0, hd.BTN_SELECT, 1), (0.05, hd.BTN_SELECT, 0), (0.4, hd.BTN_START, 0)])
asyncio.run(hd.watch_device(dev, sw, hold=0.2))
assert ran == [], ran"
  [ "$status" -eq 0 ]
  [ "$output" = "OK" ]
}
