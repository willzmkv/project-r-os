# Project-R Roadmap

> Implementation status across all subsystems. Each task maps to a step in the corresponding implementation plan.

## Legend

| Symbol | Meaning |
|---|---|
| ✅ | Complete |
| 🔄 | In progress |
| ⬜ | Pending |
| 📋 | Plan written |

---

## project-r-os — ISO Builder

**Plan:** `docs/superpowers/plans/2026-11-01-project-r-os.md` · **Repo:** [project-r-os](https://github.com/willzmkv/project-r-os)

| # | Task | Status |
|---|---|---|
| 1 | profiledef.sh + Makefile scaffold | 📋 |
| 2 | packages.x86_64 + project-r-packages.x86_64 | 📋 |
| 3 | pacman.conf + project-r.conf + release file | 📋 |
| 4 | customize_airootfs.sh — arcade user, auto-login, xinitrc | 📋 |
| 5 | EFI + BIOS boot entries | 📋 |
| 6 | project-r-repo Makefile + PKGBUILD stubs | 📋 |
| 7 | Calamares post-install hook | 📋 |
| 8 | bats tests — package list verification (35 tests) | 📋 |
| 9 | bats tests — ISO build integrity (13 tests) | 📋 |
| 10 | Full build + QEMU boot test | 📋 |

---

## pr-mediad — Media Detection Daemon

**Plan:** `docs/superpowers/plans/2026-11-01-pr-mediad.md` · **Repo:** [pr-mediad](https://github.com/willzmkv/pr-mediad)

| # | Task | Status |
|---|---|---|
| 1 | CMake scaffold + cJSON vendor + stub files | 📋 |
| 2 | platform_db.h/c — 23 platforms, PlatformInfo, signatures | 📋 |
| 3 | media_detect.h/c — magic bytes, filesystem, ROM detection | 📋 |
| 4 | ipc.h/c — Unix socket client + cJSON serialization | 📋 |
| 5 | notify.h/c — libnotify wrapper | 📋 |
| 6 | main.c — udev monitor loop | 📋 |
| 7 | pr-mediad.service systemd unit | 📋 |
| 8 | PKGBUILD | 📋 |

---

## pr-builder — Build Orchestrator

**Plan:** `docs/superpowers/plans/2026-11-01-pr-builder.md` · **Repo:** [pr-builder](https://github.com/willzmkv/pr-builder)

| # | Task | Status |
|---|---|---|
| 1 | pyproject.toml scaffold + registry JSON files | 📋 |
| 2 | registry.py — DecompEntry, EmuForkEntry, Registry (7 tests) | 📋 |
| 3 | deps.py — ensure_deps() async pacman wrapper | 📋 |
| 4 | builder.py — run_build(), BuildResult (3 async tests) | 📋 |
| 5 | library.py — install_native(), write_emu_meta() (5 tests) | 📋 |
| 6 | maestro_bridge.py — Unix socket diagnosis client | 📋 |
| 7 | launcher.py — launch_retroarch(), launch_standalone() (5 tests) | 📋 |
| 8 | server.py — asyncio Unix socket server, full pipeline | 📋 |
| 9 | pr-builder.service systemd unit | 📋 |
| 10 | Full suite run + git tag v0.1.0 | 📋 |

---

## pr-meta — Metadata Scraper + ES-DE

**Plan:** `docs/superpowers/plans/2026-11-01-pr-meta.md` · **Repo:** [pr-meta](https://github.com/willzmkv/pr-meta)

| # | Task | Status |
|---|---|---|
| 1 | Package scaffold + conftest + fixtures | 📋 |
| 2 | meta_writer.py — write_meta / read_meta | 📋 |
| 3 | gamelist.py — ES-DE gamelist.xml upsert with pr_badge | 📋 |
| 4 | downloader.py — async cover art + video download | 📋 |
| 5 | scrapers/screenscraper.py — REST client | 📋 |
| 6 | scrapers/igdb.py — OAuth2 + search | 📋 |
| 7 | scrapers/thegamesdb.py — fallback client | 📋 |
| 8 | scrapers/__init__.py — priority chain | 📋 |
| 9 | server.py — asyncio Unix socket server | 📋 |
| 10 | badges.py — Badge enum + IHC colors | 📋 |
| 11 | Integration smoke test: EMU→NATIVE badge flip | 📋 |

---

## Desktop Mode — KDE Plasma

**Plan:** `docs/superpowers/plans/2026-11-01-desktop-mode.md` · **Repo:** [project-r-os](https://github.com/willzmkv/project-r-os) (subdir)

| # | Task | Status |
|---|---|---|
| 1 | Repo scaffold + bats-core test infrastructure | 📋 |
| 2 | gaming-session.sh | 📋 |
| 3 | switch-to-desktop.sh | 📋 |
| 4 | return-to-gaming.sh | 📋 |
| 5 | hotkey-daemon.sh + hotkey-daemon.py (evdev) | 📋 |
| 6 | .xinitrc + project-r-session.service + pr-hotkey.service | 📋 |
| 7 | KDE Plasma minimal config (kwinrc, plasmarc, applets) | 📋 |
| 8 | retroarch.cfg — Vulkan, rewind, 11 cores, RetroAchievements | 📋 |
| 9 | Ghostty config — Project-R palette, JetBrains Mono Nerd | 📋 |
| 10 | KDE Return-to-Gaming QML widget | 📋 |
| 11 | packages.list — KDE minimal, emulators, Flatpak | 📋 |
| 12 | PKGBUILD + post_install hook | 📋 |
| 13 | kglobalshortcutsrc — Ctrl+Alt+T → Ghostty | 📋 |
| 14 | Integration smoke tests + full suite run | 📋 |

---

## pr-achieve — Achievement Overlay

**Plan:** `docs/superpowers/plans/2026-11-01-pr-achieve.md` · **Repo:** [pr-achieve](https://github.com/willzmkv/pr-achieve)

| # | Task | Status |
|---|---|---|
| 1 | Project scaffold + Achievement dataclass | 📋 |
| 2 | Config dataclass — position, theme colors, timing | 📋 |
| 3 | RetroArchSource — polls RA HTTP API | 📋 |
| 4 | SteamSource — polls userdata JSON files | 📋 |
| 5 | NativeHookSource — inotify watcher | 📋 |
| 6 | HeroicSource — GOG/Epic achievement JSON | 📋 |
| 7 | OverlayQueue — sequential asyncio queue | 📋 |
| 8 | OverlayWindow — PyQt6 frameless animated overlay | 📋 |
| 9 | daemon.py — asyncio main loop | 📋 |
| 10 | pr-achieve.service — systemd user service | 📋 |
| 11 | Full test suite verification | 📋 |

---

## pr-controller — Controller Daemon

**Plan:** `docs/superpowers/plans/2026-11-01-pr-controller.md` · **Repo:** [pr-controller](https://github.com/willzmkv/pr-controller)

| # | Task | Status |
|---|---|---|
| 1 | Package scaffold + pyproject.toml | 📋 |
| 2 | config.py — XDG_CONFIG_HOME path constants | 📋 |
| 3 | device_db.py — vendor/product ID lookup, PS/Xbox/SNES layouts | 📋 |
| 4 | profile_manager.py — 3-level deep-merge resolution | 📋 |
| 5 | RetroArch autoconfig writer | 📋 |
| 6 | ES-DE XML config writer | 📋 |
| 7 | SDL gamecontrollerdb writer | 📋 |
| 8 | sdl_wrapper.py — ctypes abstraction, SDL3→SDL2 fallback | 📋 |
| 9 | daemon.py — pyudev monitor loop, notify pr-builder | 📋 |
| 10 | PKGBUILD + systemd user service | 📋 |
| 11 | Full integration run (41 tests) | 📋 |

---

## pr-maestro — AI Bridge

**Plan:** `docs/superpowers/plans/2026-11-01-pr-maestro.md` · **Repo:** [pr-maestro](https://github.com/willzmkv/pr-maestro)

| # | Task | Status |
|---|---|---|
| 1 | package.json — ESM + Jest config, stub files | 📋 |
| 2 | Prompt templates — buildDiagnosisPrompt, platformIdentifyPrompt | 📋 |
| 3 | Maestro MCP client — Claude + Codex + Gemini | 📋 |
| 4 | OpenCode CLI wrapper — Groq/Ollama fallback | 📋 |
| 5 | REA MCP client — Ghidra binary analysis | 📋 |
| 6 | Orchestrator — full degradation chain (6 tests) | 📋 |
| 7 | Unix socket server — line-buffered JSON | 📋 |
| 8 | pr-maestro.service — systemd unit | 📋 |
| 9 | Smoke test + manual netcat test | 📋 |

---

## decomp-registry — Game Registry

**Repo:** [decomp-registry](https://github.com/willzmkv/decomp-registry)

| Item | Status |
|---|---|
| decomp_registry.json — sm64, Zelda64, OoT, MM, ... | 📋 |
| emu_forks_registry.json — ShadPS4/KytyPS5 game forks | 📋 |
| JSON schema + validation script | 📋 |
| CONTRIBUTING guide for adding new decomps | 📋 |

---

## pr-theme — ES-DE Theme

**Repo:** [pr-theme](https://github.com/willzmkv/pr-theme)

| Item | Status |
|---|---|
| Base theme XML | 📋 |
| NATIVE badge (#4ecdc4) | 📋 |
| EMU badge (#f5a623) | 📋 |
| BUILD ERROR badge (#e94560) | 📋 |
| IN PROGRESS badge (#4a9eff) | 📋 |
| Artwork templates | 📋 |
