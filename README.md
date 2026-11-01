# Project-R OS

> CachyOS-based arcade Linux distribution — decompile, recompile, and play from physical media.

**Status:** Pre-alpha · All subsystems in active development

## What is Project-R?

Project-R is a personal gaming OS built on CachyOS (Arch Linux + BORE scheduler). Insert a disc or cartridge and the system automatically decompiles the game to a native Linux binary. No emulation when a native port exists. RetroArch handles the rest.

```
Physical media → pr-mediad → pr-builder → Native binary  (badge: NATIVE)
                                        → RetroArch core  (badge: EMU)
```

## Architecture

| Layer | Component | Description |
|---|---|---|
| OS | project-r-os | CachyOS ISO + PKGBUILD repo |
| Detection | pr-mediad | udev/libblkid C daemon |
| Build | pr-builder | Python decompilation orchestrator |
| Metadata | pr-meta | ScreenScraper → IGDB scraper + ES-DE gamelist |
| Frontend | ES-DE | EmulationStation-DE (Gaming Mode) |
| Desktop | KDE Plasma | Desktop Mode — Steam, Heroic, Lutris, Bazaar |
| Achievements | pr-achieve | PyQt6 overlay — RetroAchievements + Steam |
| Controllers | pr-controller | SDL2/3 daemon — 3-level profiles |
| AI | pr-maestro | Maestro MCP + REA + OpenCode bridge |

## Repositories

| Repo | Description |
|---|---|
| [project-r-os](https://github.com/willzmkv/project-r-os) | ISO builder, mkarchiso, PKGBUILD repo |
| [pr-mediad](https://github.com/willzmkv/pr-mediad) | C daemon — udev/libblkid disc & ROM detection |
| [pr-builder](https://github.com/willzmkv/pr-builder) | Python — decompilation/recompilation orchestrator |
| [pr-meta](https://github.com/willzmkv/pr-meta) | Python — metadata scraper + ES-DE gamelist |
| [pr-maestro](https://github.com/willzmkv/pr-maestro) | Node.js — Maestro MCP + REA + OpenCode |
| [pr-achieve](https://github.com/willzmkv/pr-achieve) | Python/PyQt6 — achievement overlay |
| [pr-controller](https://github.com/willzmkv/pr-controller) | Python — SDL2/3 controller daemon |
| [decomp-registry](https://github.com/willzmkv/decomp-registry) | JSON — decompilation & emulator fork registry |
| [pr-theme](https://github.com/willzmkv/pr-theme) | ES-DE theme + IHC badge assets |

## Roadmap

See [ROADMAP.md](ROADMAP.md) for full implementation status.

### Implementation Order

1. **project-r-os** — ISO scaffold, package lists, auto-login
2. **pr-mediad** — C daemon, udev, magic bytes detection
3. **pr-builder** — Python orchestrator, build pipeline, AI diagnosis
4. **pr-meta** — Metadata scraper, ES-DE gamelist, badge writer
5. **Desktop Mode** — KDE config, session switching, Ghostty, Flatpak
6. **pr-achieve** — Achievement overlay, RetroAchievements + Steam
7. **pr-controller** — SDL2/3 daemon, 3-level profiles
8. **pr-maestro** — Maestro MCP + REA + OpenCode bridge

## Tech Stack

- **OS:** CachyOS (Arch Linux, BORE scheduler, linux-cachyos kernel)
- **Frontend:** ES-DE (EmulationStation-DE)
- **Emulation:** RetroArch + RPCS3, Xenia Canary, ShadPS4, Eden, KytyPS5
- **Build system:** mkarchiso + pacman
- **Languages:** C (pr-mediad), Python (pr-builder, pr-meta, pr-achieve, pr-controller), Node.js (pr-maestro)
- **AI:** Maestro MCP (Claude + Codex + Gemini), REA (Ghidra binary analysis), OpenCode (Groq/Ollama fallback)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). All subsystems have detailed implementation plans in `docs/superpowers/plans/`.

## License

GPL-3.0
