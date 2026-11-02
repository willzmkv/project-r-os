#!/usr/bin/env python3
"""
hotkey-daemon.py — evdev listener for the Start+Select gamepad combo.

Runs switch-to-desktop.sh (Gaming Mode) or return-to-gaming.sh (Desktop Mode)
depending on the mode recorded in $XDG_RUNTIME_DIR/pr-session.

Button codes (Linux evdev, standard gamepad mapping — xpad, hid-playstation,
hid-nintendo, most 8BitDo/generic pads):
  BTN_START  = 315  (Start / Options / +)
  BTN_SELECT = 314  (Select / Back / Share / -)

Both must be held on the same pad for PR_HOTKEY_HOLD seconds (default 2.0).
The hold is deliberately longer than a tap so it does not collide with
RetroArch's Start+Select quit combo. After a trigger, further combos are
ignored for PR_HOTKEY_COOLDOWN seconds (default 5) while the session switches.

Usage: hotkey-daemon.py [SCRIPTS_DIR]
"""

import asyncio
import os
import subprocess
import sys
import time
from pathlib import Path

try:
    import evdev
    from evdev import InputDevice, ecodes

    BTN_START = ecodes.BTN_START
    BTN_SELECT = ecodes.BTN_SELECT
except ImportError:  # the pure logic below stays importable (tests)
    evdev = None
    BTN_START = 315
    BTN_SELECT = 314

KEY_UP, KEY_DOWN = 0, 1  # evdev EV_KEY values; 2 = autorepeat (ignored)

HOLD_DURATION = float(os.environ.get("PR_HOTKEY_HOLD", "2.0"))
COOLDOWN = float(os.environ.get("PR_HOTKEY_COOLDOWN", "5.0"))
RESCAN_INTERVAL = 5.0
SESSION_FILE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "pr-session"


def log(msg: str) -> None:
    print(f"hotkey-daemon: {msg}", flush=True)


class ComboDetector:
    """Start+Select state of ONE device. Pure logic: time is passed in."""

    def __init__(self, hold: float = HOLD_DURATION):
        self.hold = hold
        self.held: set[int] = set()
        self.since: float | None = None  # when both buttons became held
        self.fired = False  # already fired for the current press

    def feed(self, code: int, value: int, now: float) -> None:
        if code not in (BTN_START, BTN_SELECT) or value not in (KEY_UP, KEY_DOWN):
            return
        if value == KEY_DOWN:
            self.held.add(code)
        else:
            self.held.discard(code)
        if self.held == {BTN_START, BTN_SELECT}:
            if self.since is None:
                self.since = now
        else:
            self.since = None
            self.fired = False

    @property
    def pending(self) -> bool:
        return self.since is not None and not self.fired

    def due(self, now: float) -> bool:
        """True exactly once per press, once the combo is held long enough."""
        if not self.pending or now - self.since < self.hold:
            return False
        self.fired = True
        return True


class Switcher:
    """Chooses and runs the switch script; global cooldown across pads."""

    def __init__(self, scripts_dir: Path, session_file: Path,
                 cooldown: float = COOLDOWN, run=None):
        self.scripts_dir = Path(scripts_dir)
        self.session_file = Path(session_file)
        self.cooldown = cooldown
        self.run = run or self._spawn
        self.last: float | None = None

    def current_session(self) -> str:
        try:
            return self.session_file.read_text().strip() or "gaming"
        except OSError:
            return "gaming"

    def target_script(self) -> Path:
        if self.current_session() == "desktop":
            return self.scripts_dir / "return-to-gaming.sh"
        return self.scripts_dir / "switch-to-desktop.sh"

    def trigger(self, now: float) -> Path | None:
        if self.last is not None and now - self.last < self.cooldown:
            return None
        self.last = now
        script = self.target_script()
        self.run(script)
        return script

    @staticmethod
    def _spawn(script: Path) -> None:
        log(f"combo detected, running {script.name}")
        # Own session: the script must outlive whatever it tears down.
        subprocess.Popen(["bash", str(script)], start_new_session=True)


def is_gamepad(dev) -> bool:
    keys = dev.capabilities().get(ecodes.EV_KEY, [])
    return BTN_START in keys and BTN_SELECT in keys


async def watch_device(dev, switcher: Switcher, hold: float = HOLD_DURATION) -> None:
    detector = ComboDetector(hold)
    timer: asyncio.Task | None = None

    async def fire_when_held() -> None:
        await asyncio.sleep(detector.hold)
        now = time.monotonic()
        if detector.due(now):
            switcher.trigger(now)

    try:
        async for event in dev.async_read_loop():
            if event.type != ecodes.EV_KEY:
                continue
            detector.feed(event.code, event.value, time.monotonic())
            if detector.pending and (timer is None or timer.done()):
                timer = asyncio.create_task(fire_when_held())
            elif not detector.pending and timer is not None and not timer.done():
                timer.cancel()
    except OSError:
        log(f"{dev.path} disconnected")
    finally:
        if timer is not None:
            timer.cancel()
        dev.close()


async def main(scripts_dir: Path) -> None:
    switcher = Switcher(scripts_dir, SESSION_FILE)
    watched: dict[str, asyncio.Task] = {}
    ignored: set[str] = set()   # non-gamepad devices
    failed: set[str] = set()    # could not open (logged once, retried)
    announced_none = False

    while True:
        paths = set(evdev.list_devices())
        ignored &= paths
        failed &= paths
        for path, task in list(watched.items()):
            if task.done():
                del watched[path]

        for path in sorted(paths - ignored - watched.keys()):
            try:
                dev = InputDevice(path)
            except OSError as e:
                if path not in failed:
                    log(f"cannot open {path}: {e}")
                    failed.add(path)
                continue
            failed.discard(path)
            if not is_gamepad(dev):
                dev.close()
                ignored.add(path)
                continue
            log(f"watching {dev.name} ({path})")
            watched[path] = asyncio.create_task(watch_device(dev, switcher))

        if not watched and not announced_none:
            log(f"no gamepads found, rescanning every {RESCAN_INTERVAL:.0f}s")
        announced_none = not watched
        await asyncio.sleep(RESCAN_INTERVAL)


if __name__ == "__main__":
    if evdev is None:
        sys.exit("hotkey-daemon: python-evdev is not installed")
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent
    try:
        asyncio.run(main(target))
    except KeyboardInterrupt:
        pass
