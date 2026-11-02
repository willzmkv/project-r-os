# Project-R Roadmap

> Implementation status across all subsystems. Each task maps to a step in the corresponding implementation plan.
> **Last updated:** 2026-11-02. Cross-service issues: `D:\Project-R\docs\superpowers\plans\2026-11-02-integration-issues.md` (workspace doc).

## Legend

| Symbol | Meaning |
|---|---|
| ✅ | Complete (tests verified) |
| 🔄 | In progress |
| ⬜ | Pending |
| 📋 | Plan written |

## Overview

| Subsystem | Status | Tests | Ref |
|---|---|---|---|
| project-r-os (ISO) | 🔄 boots to ES-DE; session fixes await rebuild | 37 bats (packages) | `main` @ beb6198 |
| pr-mediad | ✅ v0.1.0 | 4 ctest suites / 27 cases | b4daa41 |
| pr-builder | ✅ v0.1.0 (+ socket fix) | 64 pytest | c290982 |
| pr-meta | ✅ (no tag yet) | 49 pytest, 95.7% cov | fa83dc8 |
| pr-maestro | ✅ (no tag yet) | 51 jest | 4426e8f |
| pr-controller | ✅ v0.1.0 | 108 pytest | c813bb6 |
| pr-achieve | 🔄 tasks 1–7 of 11 | 60 pytest | `main` + `wip/2026-11-02-overlay-window` |
| Desktop Mode | 🔄 tasks 1–6 of 14 | 36 bats | branch `feat/desktop-mode` |
| decomp-registry | 🔄 schema work started | — | branch `wip/2026-11-02` |
| pr-theme | 🔄 theme scaffold started | — | branch `wip/2026-11-02` |

---

## project-r-os — ISO Builder

**Plan:** `docs/superpowers/plans/2026-11-01-project-r-os.md` · **Repo:** [project-r-os](https://github.com/willzmkv/project-r-os)

| # | Task | Status |
|---|---|---|
| 1 | profiledef.sh + Makefile scaffold | ✅ |
| 2 | packages.x86_64 + project-r-packages.x86_64 | ✅ (+ mkinitcpio-archiso, lib32 Vulkan) |
| 3 | pacman.conf + project-r.conf + release file | ✅ |
| 4 | customize_airootfs.sh — arcade user, auto-login, xinitrc | ✅ (`es-de`, ES-DE 3.x settings path, firstboot off) |
| 5 | EFI + BIOS boot entries | ✅ (BIOS boot verified in QEMU) |
| 6 | project-r-repo Makefile + PKGBUILD stubs | ✅ stubs — real `pr-*` PKGBUILDs pending (wave 4) |
| 7 | Calamares post-install hook | 🔄 config present, never tested |
| 8 | bats tests — package list verification | ✅ 37/37 |
| 9 | bats tests — ISO build integrity | ✅ |
| 10 | Full build + QEMU boot test | 🔄 ISO 2026.11.02 boots to ES-DE with autologin (after live `.xinitrc` patch); rebuild with committed fixes pending |

---

## pr-mediad — Media Detection Daemon

**Plan:** `docs/superpowers/plans/2026-11-01-pr-mediad.md` · **Repo:** [pr-mediad](https://github.com/willzmkv/pr-mediad)

| # | Task | Status |
|---|---|---|
| 1 | CMake scaffold + cJSON vendor + stub files | ✅ |
| 2 | platform_db.h/c — platforms, PlatformInfo, signatures | ✅ (Wii magic fixed to 0x18) |
| 3 | media_detect.h/c — magic bytes, filesystem, ROM detection | ✅ |
| 4 | ipc.h/c — Unix socket client + cJSON serialization | ✅ |
| 5 | notify.h/c — libnotify wrapper | ✅ (no session bus from system service — open issue) |
| 6 | main.c — udev monitor loop | ✅ (disc stays mounted until eject) |
| 7 | pr-mediad.service systemd unit + tmpfiles.d | ✅ |
| 8 | PKGBUILD | ✅ makepkg + pacman -U verified |

---

## pr-builder — Build Orchestrator

**Plan:** `docs/superpowers/plans/2026-11-01-pr-builder.md` · **Repo:** [pr-builder](https://github.com/willzmkv/pr-builder)

| # | Task | Status |
|---|---|---|
| 1 | pyproject.toml scaffold + registry JSON files | ✅ |
| 2 | registry.py — DecompEntry, EmuForkEntry, Registry | ✅ |
| 3 | deps.py — ensure_deps() async pacman wrapper | ✅ |
| 4 | builder.py — run_build(), BuildResult | ✅ |
| 5 | library.py — install_native(), write_emu_meta() | ✅ |
| 6 | maestro_bridge.py — Unix socket diagnosis client | ✅ (pr-maestro contract) |
| 7 | launcher.py — launch_retroarch(), launch_standalone() | ✅ |
| 8 | server.py — asyncio Unix socket server, full pipeline | ✅ (+ meta_bridge.py) |
| 9 | pr-builder.service systemd unit | ✅ |
| 10 | Full suite run + git tag v0.1.0 | ✅ 64 passed |

---

## pr-meta — Metadata Scraper + ES-DE

**Plan:** `docs/superpowers/plans/2026-11-01-pr-meta.md` · **Repo:** [pr-meta](https://github.com/willzmkv/pr-meta)

| # | Task | Status |
|---|---|---|
| 1 | Package scaffold + conftest + fixtures | ✅ |
| 2 | meta_writer.py — write_meta / read_meta | ✅ |
| 3 | gamelist.py — ES-DE gamelist.xml upsert with pr_badge | ✅ (theme can't read `pr_badge` — see pr-theme) |
| 4 | downloader.py — async cover art + video download | ✅ |
| 5 | scrapers/screenscraper.py — REST client | ✅ (mocked only) |
| 6 | scrapers/igdb.py — OAuth2 + search | ✅ (mocked only) |
| 7 | scrapers/thegamesdb.py — fallback client | ✅ (mocked only) |
| 8 | scrapers/__init__.py — priority chain | ✅ |
| 9 | server.py — asyncio Unix socket server | ✅ socket `/run/project-r/pr-meta.sock` + systemd unit |
| 10 | badges.py — Badge enum + IHC colors | ✅ |
| 11 | Integration smoke test: EMU→NATIVE badge flip | ✅ |

---

## Desktop Mode — KDE Plasma

**Plan:** `docs/superpowers/plans/2026-11-01-desktop-mode.md` · **Branch:** `feat/desktop-mode` (package `project-r-repo/project-r-desktop-mode/`)

| # | Task | Status |
|---|---|---|
| 1 | Repo scaffold + bats-core test infrastructure | ✅ |
| 2 | gaming-session.sh | ✅ |
| 3 | switch-to-desktop.sh | ✅ |
| 4 | return-to-gaming.sh | ✅ |
| 5 | hotkey-daemon.sh + hotkey-daemon.py (evdev) | ✅ |
| 6 | .xinitrc + project-r-session + pr-hotkey.service | ✅ |
| 7 | KDE Plasma minimal config (kwinrc, plasmarc, applets) | 🔄 WIP commit |
| 8 | retroarch.cfg — Vulkan, rewind, cores, RetroAchievements | ⬜ |
| 9 | Ghostty config — Project-R palette, JetBrains Mono Nerd | ⬜ |
| 10 | KDE Return-to-Gaming QML widget | ⬜ |
| 11 | packages.list — KDE minimal, emulators, Flatpak | ⬜ |
| 12 | PKGBUILD + post_install hook | ⬜ |
| 13 | kglobalshortcutsrc — Ctrl+Alt+T → Ghostty | ⬜ |
| 14 | Integration smoke tests + full suite run | ⬜ |

---

## pr-achieve — Achievement Overlay

**Plan:** `docs/superpowers/plans/2026-11-01-pr-achieve.md` · **Repo:** [pr-achieve](https://github.com/willzmkv/pr-achieve)

| # | Task | Status |
|---|---|---|
| 1 | Project scaffold + Achievement dataclass | ✅ |
| 2 | Config dataclass — position, theme colors, timing | ✅ |
| 3 | RetroArchSource — polls RA HTTP API | ✅ |
| 4 | SteamSource — polls userdata JSON files | ✅ |
| 5 | NativeHookSource — inotify watcher | ✅ |
| 6 | HeroicSource — GOG/Epic achievement JSON | ✅ |
| 7 | OverlayQueue — sequential asyncio queue | ✅ |
| 8 | OverlayWindow — PyQt6 frameless animated overlay | 🔄 branch `wip/2026-11-02-overlay-window` |
| 9 | daemon.py — asyncio main loop | ⬜ |
| 10 | pr-achieve.service — systemd user service | ⬜ |
| 11 | Full test suite verification | ⬜ |

---

## pr-controller — Controller Daemon

**Plan:** `docs/superpowers/plans/2026-11-01-pr-controller.md` · **Repo:** [pr-controller](https://github.com/willzmkv/pr-controller)

| # | Task | Status |
|---|---|---|
| 1 | Package scaffold + pyproject.toml | ✅ |
| 2 | config.py — XDG_CONFIG_HOME path constants | ✅ |
| 3 | device_db.py — vendor/product ID lookup | ✅ |
| 4 | profile_manager.py — 3-level deep-merge resolution | ✅ |
| 5 | RetroArch autoconfig writer | ✅ |
| 6 | ES-DE XML config writer | ✅ |
| 7 | SDL gamecontrollerdb writer | ✅ |
| 8 | sdl_wrapper.py — ctypes abstraction, SDL3→SDL2 fallback | ✅ |
| 9 | daemon.py — pyudev monitor loop, notify pr-builder | ✅ |
| 10 | PKGBUILD + systemd user service | ✅ |
| 11 | Full integration run | ✅ 108 passed |

---

## pr-maestro — AI Bridge

**Plan:** `docs/superpowers/plans/2026-11-01-pr-maestro.md` · **Repo:** [pr-maestro](https://github.com/willzmkv/pr-maestro)

| # | Task | Status |
|---|---|---|
| 1 | package.json — ESM + Jest config, stub files | ✅ |
| 2 | Prompt templates | ✅ |
| 3 | Maestro MCP client (MCP initialize handshake) | ✅ (not tested against live Maestro) |
| 4 | OpenCode CLI wrapper | ✅ (`opencode run`) |
| 5 | REA MCP client | ✅ but REA real API differs — always null (open issue) |
| 6 | Orchestrator — degradation chain | ✅ |
| 7 | Unix socket server — line-buffered JSON | ✅ |
| 8 | pr-maestro.service — systemd unit | ✅ |
| 9 | Smoke test | ✅ (fake MCP servers) |

---

## decomp-registry — Game Registry

**Repo:** [decomp-registry](https://github.com/willzmkv/decomp-registry) · **Branch:** `wip/2026-11-02`

| Item | Status |
|---|---|
| Convert to pr-builder's dict schema | 🔄 |
| decomp_registry.json — verified hashes only | ⬜ |
| emu_forks_registry.json — verified forks only (spec examples are placeholders) | ⬜ |
| JSON schema + validation script + tests via pr-builder Registry | 🔄 schemas drafted |
| CONTRIBUTING guide for adding new decomps | ⬜ |

---

## pr-theme — ES-DE Theme

**Repo:** [pr-theme](https://github.com/willzmkv/pr-theme) · **Branch:** `wip/2026-11-02`

| Item | Status |
|---|---|
| Badge mechanism ES-DE 3.x supports (+ contract for pr-meta) | 🔄 |
| Base theme XML (theme.xml, capabilities.xml) | 🔄 drafted |
| NATIVE / EMU / BUILDING / BUILD ERROR badges | 🔄 asset generator in progress |
| Validation script + CI | 🔄 |
| Artwork templates (original, no trademarked logos) | ⬜ |
