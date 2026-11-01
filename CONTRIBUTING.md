# Contributing to Project-R

Project-R is an open-source arcade Linux OS. Contributions welcome across all subsystems.

## Subsystems

Each subsystem lives in its own repository. Pick one that interests you:

| Repo | Language | Skills needed |
|---|---|---|
| [project-r-os](https://github.com/willzmkv/project-r-os) | Bash, mkarchiso | Arch packaging, shell scripting |
| [pr-mediad](https://github.com/willzmkv/pr-mediad) | C | udev, libblkid, Unix sockets |
| [pr-builder](https://github.com/willzmkv/pr-builder) | Python | asyncio, subprocess, game modding |
| [pr-meta](https://github.com/willzmkv/pr-meta) | Python | REST APIs, XML, async |
| [pr-maestro](https://github.com/willzmkv/pr-maestro) | Node.js | MCP protocol, LLM APIs |
| [pr-achieve](https://github.com/willzmkv/pr-achieve) | Python | PyQt6, asyncio, inotify |
| [pr-controller](https://github.com/willzmkv/pr-controller) | Python | SDL2/3, udev, ctypes |
| [decomp-registry](https://github.com/willzmkv/decomp-registry) | JSON | Game decompilation knowledge |
| [pr-theme](https://github.com/willzmkv/pr-theme) | XML, SVG | ES-DE theming, design |

## Adding a game to decomp-registry

The most impactful contribution is adding a new decompilation project to `decomp_registry.json`.

```json
{
  "rom_hash_md5": "YOUR_ROM_MD5",
  "project_id": "game-region",
  "display_name": "Game Name (Region)",
  "repo": "https://github.com/org/repo",
  "build_system": "make",
  "deps": ["package1", "package2"],
  "output_binary": "build/game"
}
```

Run `python validate_registry.py` before submitting.

## Adding an emulator fork to emu_forks_registry

For ShadPS4 or KytyPS5 game-specific forks:

```json
{
  "emulator": "shadps4",
  "game_id": "GAME_ID",
  "display_name": "Game Name",
  "fork_repo": "https://github.com/org/shadps4-game",
  "stability": "stable",
  "notes": "Reason this fork exists"
}
```

`stability` must be `"stable"` or `"experimental"`.

## Development Setup

Each repo has its own setup instructions in its README. All use:
- Python 3.11+ (pr-builder, pr-meta, pr-achieve, pr-controller)
- Node.js 20+ (pr-maestro)
- CMake 3.25+ (pr-mediad)
- bats-core (project-r-os tests)

## Pull Requests

1. Fork the target repo
2. Create a branch: `git checkout -b feat/description`
3. Follow TDD: write tests first
4. Run the full test suite before submitting
5. Reference the relevant plan task in your PR description

## Code Style

- Python: black + ruff (configs in pyproject.toml)
- C: clang-format (`.clang-format` in repo root)
- Node.js: ESLint + Prettier
- Shell: shellcheck

## IHC Badge Colors

All UI contributions must follow the Project-R IHC guidelines:

| Badge | Color | Meaning |
|---|---|---|
| NATIVE | `#4ecdc4` (teal) | Native binary, zero emulation |
| EMU | `#f5a623` (yellow) | Emulation — informative |
| IN PROGRESS | `#4a9eff` (blue) | Build running |
| BUILD ERROR | `#e94560` (red) | Error — red = error only |

Never use red for non-error states.
